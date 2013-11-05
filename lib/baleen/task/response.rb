require "baleen/task/base"
require 'baleen/utils/colored_puts'

module Baleen
  class SimpleMessage < Task::Base
    def initialize(opt)
      super()
      @params[:message]       = opt[:message]
      @params[:message_level] = opt[:message_level]
    end

    def print_message
      case message_level
        when "info"
          info message
        when "warn"
          warn message
        when ""
      end
    end
  end
end