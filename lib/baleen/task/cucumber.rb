require "baleen/task/task"

module Baleen
  module Task
    class Cucumber < Baleen::Task::Base

      include Serializable
      include Baleen::Default

      attr_reader :target_files

      def initialize(opt)
        super()
        @params[:shell]          = opt[:shell]          || "/bin/bash"
        @params[:opt]            = opt[:opt]            || "-c"
        @params[:exe]            = opt[:exe]            || "bundle exec cucumber"
        @params[:work_dir]       = opt[:work_dir]       || default_work_dir
        @params[:files]          = opt[:files]          || default_features
        @params[:concurrency]    = opt[:concurrency]    || default_concurrency
        @params[:before_command] = opt[:before_command] || default_before_command
        @params[:image]          = opt[:image]
        @params[:command]        = opt[:command]
        @params[:results]        = opt[:results]
        @params[:status]         = opt[:status]
        @params[:commit]         = nil
      end

      def prepare
        task = Generic.new(
          shell:    shell,
          opt:      opt,
          work_dir: work_dir,
          image:    image,
          command:  %{find #{files} | grep "\\.feature"}
        )
        runner = Baleen::Runner.new(task)
        result = runner.run
        @target_files = result[:stdout]
      end

    end

  end
end