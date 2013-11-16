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
        response = handle_response(@socket.gets)
        return response if response
      }
    end

    def close
      @socket.close if @socket
      colored_warn "Connection closed"

    rescue IOError; nil
    end

    def handle_response(msg)
      if msg.nil?
        raise RuntimeError, 'Connection closed by server'
      end

      response = Serializable.deserialize(msg)

      if response.is_a? Message::Base
        response.print_message
      end

      if response.terminate?
        response
      else
        nil
      end
    end

  end
end