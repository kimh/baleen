module Baleen
  class Connection
    def initialize(socket=nil)
      @socket = socket
    end

    def notify_info(msg)
      response = Baleen::SimpleMessage.new({:message => msg, :message_level => "info"})
      write(response.to_json)
    end

    def respond(response)
      write(response.to_json)
    end

    private

    def write(json_data)
      if @socket
        @socket.puts(json_data)
      else
        nil
      end
    end
  end
end