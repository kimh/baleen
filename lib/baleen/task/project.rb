require "baleen/task/task"

module Baleen
  module Task
    class Project < Baleen::Task::Base

      def initialize(opt)
        super()
        @params[:project] = opt[:project]
      end

    end
  end
end