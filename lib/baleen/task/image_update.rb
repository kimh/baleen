require "baleen/task/task"

module Baleen
  module Task
    class ImageUpdate < Base

      include Serializable

      def initialize(opt)
        super()
        @params[:shell]          = opt[:shell]       ||="/bin/bash"
        @params[:opt]            = opt[:opt]         ||="-c"
        @params[:image]          = opt[:image]       ||="kimh/baleen-poc"
        @params[:command]        = opt[:command]
        @params[:work_dir]       = opt[:work_dir]
        @params[:files]          = "" # Without this, #start_runner raises exception. Need to think what to do.
        @params[:concurrency]    = 1
        @params[:commit]         = true
      end
    end
  end
end