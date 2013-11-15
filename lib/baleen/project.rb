module Baleen
  module Project
    class Base

      attr_reader :config

      def initialize(cfg)
        load_config(cfg)
      end

      def load_config(cfg)
        if Baleen::Config::Validator.check(cfg)
          cfg[:runner][:before_command] ||= default_before_command
          cfg[:runner][:concurrency]    ||= default_concurrency
          cfg[:runner][:work_dir]       ||= default_work_dir
          cfg[:runner][:image]

          case cfg[:framework][:type]
            when "cucumber"
              cfg[:framework][:files] = cfg[:framework][:features] || default_features
            else
              raise "Passed unknown framework from config yml: #{cfg[:framework][:type]}"
          end
        end
        @config = cfg
      end

      def task
        nil
      end
    end

    class Cucumber < Base
     def task
        Baleen::Task::Cucumber.new(
          image: config[:runner][:image],
          work_dir: config[:runner][:work_dir],
          files: config[:framework][:files],
          before_command: config[:runner][:before_command],
          concurrency: config[:runner][:concurrency].to_i,
        )
      end
    end
  end
end