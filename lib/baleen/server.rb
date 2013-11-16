require 'docker'
require 'socket'
require 'celluloid/io'
require 'celluloid/autostart'
require 'json'

module Baleen

  class Server
    include Celluloid::IO
    finalizer :shutdown

    def initialize(docker_host, docker_port, port, config)
      Docker.url = "http://#{docker_host}:#{docker_port}"
      @server = TCPServer.new("0.0.0.0", port)
      load_project(config)
      async.run
    end

    def load_project(config)
      @projects = {}
      if File.exists?(config)
        yaml = Baleen::Serializable.symbolize_keys(YAML.load_file(config))
      else
        colored_error "Config file not found"
        raise Baleen::Error::ConfigMissing
      end

      yaml.each do |project, cfg|
        if Baleen::Config::Validator.check(cfg)
          @projects[project] = Baleen::Project::Cucumber.new(cfg)
        end
      end
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def shutdown
      begin
        @server.close
      rescue IOError
        colored_info "Shutting down baleen-server..."
      end
    end

    def handle_connection(socket)
      loop { handle_request(socket) }

    rescue Exception => ex
      case ex
        when IOError; nil # when trying to close already closed socket
        else
          puts ex.inspect
          raise ex
      end
    end

    def handle_request(socket)
      json_request = socket.gets

      if json_request.nil?
        socket.close
        return
      end

      conn = Connection.new(socket)
      request = parse_request(json_request)

      begin
        if request.is_a? Baleen::Task::Project
          task = find_project(request.project, conn).task
        else
          task = request # request itself is a task
        end
      rescue Baleen::Error::ProjectNotFound
        #conn.close
        return
      end

      RunnerManager.new(conn, task).run do |response|
        conn.respond(response)
      end
    end

    def parse_request(request)
      Serializable.deserialize(request)
    end

    def find_project(name, conn)
      project = @projects[name.to_sym]

      unless project
        conn.notify_error("Cannot find #{name} project")
        conn.notify_exception("Exception HAPPENS")
        raise Baleen::Error::ProjectNotFound
      end

      project
    end
  end
end

