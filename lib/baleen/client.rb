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
          return response
        end
      }
    end

    def close
      @socket.close if @socket
      info "connection closed"

    rescue IOError; nil
    end

    def handle_response(response)
      if response.nil?
        raise RuntimeError, 'Connection closed by server'
      end

      Baleen::Message::Decoder.new(response).decode
    end

  end
end