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
      async.run
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
      json_task = socket.gets

      if json_task.nil?
        socket.close
        return
      end

      conn = Connection.new(socket)
      manager = RunnerManager.new(conn, parse_request(json_task))
      manager.run do |response|
        conn.respond(response)
      end
    end

    def parse_request(json_task)
      Serializable.deserialize(json_task)
    end
  end
end

