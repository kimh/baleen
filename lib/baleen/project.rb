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
          raise
        end

        begin
          validator = Baleen::Validator.const_get("Cucumber")
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

      def base_attributes
        [
          :baleen_server,
          :port,
          :framework,
          :image,
          :concurrency,
          :work_dir,
          :before_commands,
        ]
      end

    end

    class Cucumber < Common

      def attributes
        base_attributes + [
          :features
        ]
      end

      def validate
        @config.keys.each do |k|
          unless attributes.include? k
            colored_error ":#{k} is not valid for #{self.class} project"
            exit 1
          end
        end
      end

    end

  end
end