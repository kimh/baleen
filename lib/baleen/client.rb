require 'celluloid/io'
require 'celluloid/autostart'
require 'baleen/utils/colored_puts'

module Baleen
  class Client
    include Celluloid::IO
    finalizer :close

    def initialize(host, port=12345)
      @socket = TCPSocket.open(host, port)
    end

    def request(request)
      @socket.puts(request.to_json)
    end

    def wait_response
      loop {
        if response = handle_response(@socket.gets)
          if response.kind_of? Message::Base
            response.print_message
          else
            return response
          end
        end
      }
    end

    def close
      @socket.close if @socket
      colored_info "connection closed"

    rescue IOError; nil
    end

    def handle_response(response)
      if response.nil?
        raise RuntimeError, 'Connection closed by server'
      end

      Serializable.deserialize(response)
    end

  end
end