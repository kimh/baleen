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
      Baleen::Project.load_project(config)
      async.run
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def shutdown
      begin
        @server.close
      rescue IOError
        hl_info "Shutting down baleen-server..."
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
        if request.is_a? Baleen::Task::RunProject
          task = find_project(request.project, conn).task
        else
          task = request # request itself is a task
        end
      rescue Baleen::Error::ProjectNotFound
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
      project = Baleen::Project.find_project_by_name(name.to_sym)

      unless project
        conn.notify_exception("No project found: #{name}")
        raise Baleen::Error::ProjectNotFound
      end

      project
    end
  end
end

