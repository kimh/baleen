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