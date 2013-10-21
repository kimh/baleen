require 'baleen/utils/highlighter'

module Baleen
  module Message
    class Exception < Baleen::Message::Base

      def initialize(opt)
        super()
        @params[:message] = opt[:message]
      end

      def terminate?
        true
      end

      def print_message
        hl_error message
      end
    end
  end
end