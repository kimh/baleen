require "singleton"

module Baleen
  class Configuration
    include Singleton
    include Baleen::Default

    attr_accessor :log_level, :dir

    def initialize
      @log_level = INFO
      @dir       = default_dir
    end

  end
end
