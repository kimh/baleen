require "singleton"

module Baleen
  class Configuration
    include Singleton
    include Baleen::Default

    attr_accessor :log_level, :dir, :debug

    def initialize
      @log_level = INFO
      @dir       = default_dir
    end

    def self.log_level=(level)
      instance.log_level = level
    end

    def self.debug=(bool)
      instance.debug = bool
    end

  end
end
