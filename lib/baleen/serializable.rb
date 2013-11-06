require "json"

module Baleen
  module Serializable

    def self.deserialize(json_string)
      params = JSON.parse(json_string)
      klass = params.delete "klass"
      Object.const_get(klass).new(symbolize_keys(params))
    end

    def self.symbolize_keys(hash)
      hash.inject({}){|new_hash, key_value|
        key, value = key_value
        value = symbolize_keys(value) if value.is_a?(Hash)
        new_hash[key.to_sym] = value
        new_hash
      }
    end

    # Dynamically define getter and setter for keys of @params
    def method_missing(name, *args)
      _name = name.to_s.sub("=", "")

      if @params.has_key?(_name.to_sym)
        self.class.class_eval{
          define_method "#{_name}" do
            @params[_name.to_sym]
          end
        }
        self.class.class_eval{
          define_method "#{_name}=" do |*args|
           @params[_name.to_sym] = args.first
          end
        }
        if name.to_s[-1, 1] == "="
          send(name, args.first)
        else
          send(name)
        end
      else
        raise NoMethodError.new("undefined method: #{name}", name, args)
      end
    end

    def params
      @params
    end

    def to_json
      @params.to_json
    end

    def dup
      copy_params = @params.dup
      Object.const_get(self.class.to_s).new(copy_params)
    end

  end

end
