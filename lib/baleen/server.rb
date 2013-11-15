require 'docker'
require 'socket'
require 'celluloid/io'
require 'celluloid/autostart'
require 'json'

module Baleen

  class Server
    include Celluloid::IO
    finalizer :shutdown

    def initialize(docker_host: "127.0.0.1", docker_port: 4243, port: 5533)
      Docker.url = "http://#{docker_host}:#{docker_port}"
      @server = TCPServer.new("0.0.0.0", port)
      load_project
      async.run
    end

    def load_project
      @projects = {}
      yaml = Baleen::Serializable.symbolize_keys(YAML.load_file("/Users/kimh/.baleen.yml"))
      yaml.each do |project, values|
        @projects[project] = Baleen::Project::Cucumber.new(values)
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

      if request.is_a? Baleen::Task::Project
        task = find_project(request.project).task
      else
        task = request # request itself is a task
      end

      RunnerManager.new(conn, task).run do |response|
        conn.respond(response)
      end
    end

    def parse_request(request)
      Serializable.deserialize(request)
    end

    def find_project(name)
      @projects[name.to_sym] || raise("No project found: #{name}")
    end
  end
end

