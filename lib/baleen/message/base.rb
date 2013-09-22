require "json"

module Baleen
  module Message

    def symbolize_keys(hash)
      hash.inject({}){|new_hash, key_value|
        key, value = key_value
        value = symbolize_keys(value) if value.is_a?(Hash)
        new_hash[key.to_sym] = value
        new_hash
      }
    end

    class Decoder
      include Baleen::Message

      def initialize(json_string)
        @params = JSON.parse(json_string)
      end

      def decode
        klass = @params.delete "klass"
        Object.const_get(klass).new(symbolize_keys(@params))
      end
    end

    class Base

      def initialize
        @params = {}
        @params[:klass] = self.class.to_s
      end

      def method_missing(name, *args)
        Base.class_eval{
          define_method "#{name}" do
            @params[name.to_sym]
          end
        }
        send(name)
      end

      def params
        @params
      end

      def to_json
        @params.to_json
      end
    end

  end

end
