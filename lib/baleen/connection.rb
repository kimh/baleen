module Baleen
  class Connection
    def initialize(socket=nil)
      @socket = socket
    end

    def notify_info(msg)
      notify_to_client(msg, "info")
    end

    def notify_warn(msg)
      notify_to_client(msg, "warn")
    end

    def notify_error(msg)
      notify_to_client(msg, "error")
    end

    def respond(response)
      write(response.to_json)
    end

    def close
      @socket.close
    end

    def notify_exception(msg)
      response = Baleen::Message::Exception.new({:message => msg})
      write(response.to_json)
    end

    private

    def notify_to_client(msg, level)
      response = Baleen::Message::ToClient.new({:message => msg, :level => level})
      write(response.to_json)
    end

    def write(json_data)
      if @socket
        @socket.puts(json_data)
      else
        nil
      end
    end
  end
end