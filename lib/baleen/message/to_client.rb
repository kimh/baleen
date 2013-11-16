require 'baleen/utils/colored_puts'

module Baleen
  module Message
    class ToClient < Baleen::Message::Base

      def initialize(opt)
        super()
        @params[:message] = opt[:message]
        @params[:level]   = opt[:level]
      end

      def terminate?
        false
      end

      def print_message
        case level
          when "info"
            colored_info message
          when "warn"
            colored_warn message
          when "error"
            colored_error message
          else
            colored_error "Unknown message level"
            colored_error inspect
        end
      end
    end
  end
end