require "baleen/task/task"

module Baleen
  module Task
    class RunProject < Baleen::Task::Base

      def initialize(opt)
        super()
        @params[:project] = opt[:project]
      end

    end
  end
end