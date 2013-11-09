require "yaml"

module Baleen
  module Project

    class Project

      def initialize(yaml)
        unless File.exist?(yaml)
          colored_error "#{yaml} does not exist. Please make sure file path is correct"
          exit 1
        end

        config = Baleen::Serializable.symbolize_keys(YAML.load_file(yaml))

        if Baleen::Validator::Validator.check(config)
          @config = config
        end
      end

      def config
        @config
      end

    end
  end

  module Validator
    class Validator
      def self.check(config)
        if framework = config[:framework]
          klass = framework.to_s.capitalize
        else
          raise Error::Validator::FrameworkMissing
        end

        begin
          validator = Baleen::Validator.const_get(klass)
          validator.new(config).validate
        rescue NameError
          colored_error "#{klass} is not supported type of project"
          exit 1
        end
      end
    end

    class Common
      def initialize(yaml)
        @config = yaml
      end

      def mandatory_attributes
        [
          :baleen_server,
          :framework,
          :image,
          :concurrency,
          :work_dir,
        ]
      end

      def optional_attributes
        [
          :before_commands,
        ]
      end

    end

    class Cucumber < Common

      def mandatory_attributes
        super + [
          :features,
        ]
      end

      def optional_attributes
        super + [
        ]
      end

      def attributes
        mandatory_attributes + optional_attributes
      end

      def validate
        mandatory = mandatory_attributes
        @config.keys.each do |k|
          mandatory.delete k
          unless attributes.include? k
            colored_error ":#{k} is not valid for #{self.class} project"
            return false
          end
        end

        unless mandatory.empty?
          colored_warn "Following attributes are mandatory"
          colored_error mandatory.join("\n")
          raise Baleen::Error::Validator::MandatoryMissing
        end

        true
      end

    end

  end
end