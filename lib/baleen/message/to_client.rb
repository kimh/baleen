require 'baleen/utils/highlighter'

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
            hl_info message
          when "warn"
            hl_warn message
          when "error"
            hl_error message
          else
            hl_error "Unknown message level"
            hl_error inspect
        end
      end
    end
  end
end