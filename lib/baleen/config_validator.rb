require "yaml"

module Baleen
  module Config
    class Validator

      include Baleen::Serializable

      def self.check(config)
        sections = [:runner, :framework, :github]

        sections.each do |sect|
          validator = Baleen::Config.const_get(sect.to_s.capitalize)
          unless validator.new(config).validate
            return false
          end
        end
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

    class Github < Common
      def mandatory_attributes
        [
          :url,
          :repo,
        ]
      end

      def optional_attributes
        [
        ]
      end
    end
  end
end
