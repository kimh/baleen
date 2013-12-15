require "yaml"

module Baleen
  module Validation
    class Validator

      include Baleen::Serializable

      def self.check(project)
        sections = [:runner, :framework, :ci]

        sections.each do |sect|
          validator = Baleen::Validation.const_get(sect.to_s.capitalize)
          unless validator.new(project).validate
            return false
          end
        end
      end
    end

    class Common
      def initialize(yaml)
        @section = self.class.to_s.split("::").last.downcase.to_sym
        @project  = yaml[@section]
      end

      def attributes
        mandatory_attributes + optional_attributes
      end

      def validate
        unless @project
          hl_error "Your baleen.yml is missing the following mandatory section"
          hl_warn  " :#{@section}"
          raise Baleen::Error::Validator::MandatoryMissing
        end

        mandatory = mandatory_attributes
        @project.keys.each do |k|
          mandatory.delete k
          unless attributes.include? k
            hl_error "Your baleen.yml has the following invalid attribute at :#{@section} section"
            hl_warn " :#{k}"
            return false
          end
        end

        unless mandatory.empty?
          hl_error "Following attributes are mandatory at :#{@section} section of baleen.yml"
          mandatory.each {|m| hl_warn " :#{m}"}
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
          :options,
        ]
      end

      private

      def target_files
        case @project[:type]
          when "cucumber"; :features
        end
      end
    end

    class Ci < Common
      def mandatory_attributes
        [
          :url,
          :repo,
        ]
      end

      def optional_attributes
        [
          :branch,
          :build,
        ]
      end
    end
  end
end
