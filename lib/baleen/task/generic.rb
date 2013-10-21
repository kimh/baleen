require "baleen/task/task"

module Baleen
  module Task
    class Generic < Baleen::Task::Base

      def initialize(opt)
        super()
        @params[:shell]          = opt[:shell]       ||="/bin/bash"
        @params[:opt]            = opt[:opt]         ||="-c"
        @params[:work_dir]       = opt[:work_dir]    ||="./"
        @params[:image]          = opt[:image]
        @params[:command]        = opt[:command]
      end
    end
  end
end