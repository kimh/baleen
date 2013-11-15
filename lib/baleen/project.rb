require "yaml"

module Baleen
  module Project
    class Validator

      include Baleen::Serializable

      def self.check(config)
        sections = [:runner, :framework]

        sections.each do |sect|
          validator = Baleen::Config.const_get(sect.to_s.capitalize)
          unless validator.new(config).validate
            return false
          end
        end
      end
    end

    class Cucumber

      attr_reader :config

      def initialize(cfg)
        load_config(cfg)
      end

      def load_config(cfg)
        if Baleen::Project::Validator.check(cfg)
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
        klass = @config[:framework][:type].to_s.capitalize
        Baleen::Task.const_get(klass).new(
          image: config[:runner][:image],
          work_dir: config[:runner][:work_dir],
          files: config[:framework][:files],
          before_command: config[:runner][:before_command],
          concurrency: config[:runner][:concurrency].to_i,
        )
      end
    end

    class Common
      def initialize(yaml)
        @section = self.class.to_s.split("::").last.downcase.to_sym
        @config = yaml[@section]
      end

      def attributes
        mandatory_attributes + optional_attributes
      end

      def validate
        unless @config
          colored_error "Your baleen.yml is missing the following mandatory section"
          colored_warn " :#{@section}"
          raise Baleen::Error::Validator::MandatoryMissing
        end

        mandatory = mandatory_attributes
        @config.keys.each do |k|
          mandatory.delete k
          unless attributes.include? k
            colored_error "Your baleen.yml has the following invalid attribute at :#{@section} section"
            colored_warn " :#{k}"
            return false
          end
        end

        unless mandatory.empty?
          colored_error "Following attributes are mandatory at :#{@section} section of baleen.yml"
          mandatory.each {|m| colored_warn " :#{m}"}
          raise Baleen::Error::Validator::MandatoryMissing
        end

        true
      end

    end

    class Base < Common
      def mandatory_attributes
        [
        ]
      end

      def optional_attributes
        [
        ]
      end

    end

    class Runner < Common
      def mandatory_attributes
        [
          :image,
        ]
      end

      def optional_attributes
        [
          :work_dir,
          :concurrency,
          :before_command,
        ]
      end

    end

    class Framework < Common

      def mandatory_attributes
        [
          :type,
        ]
      end

      def optional_attributes
        [
          target_files,
        ]
      end

      private

      def target_files
        case @config[:type]
          when "cucumber"; :features
        end
      end
    end
  end
end
