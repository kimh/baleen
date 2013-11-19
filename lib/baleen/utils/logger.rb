require 'singleton'
require 'colorize'
require 'logger'

module Baleen

  ERROR   = Logger::ERROR
  WARN    = Logger::WARN
  INFO    = Logger::INFO
  DEBUG   = Logger::DEBUG

  class BL
    include Singleton

    attr_reader :log

    def initialize
      config = Baleen::Configuration.instance
      if config.log_level == DEBUG
        device = STDOUT
      else
        dir = File.join(config.dir, "log")
        FileUtils.mkdir_p dir
        device = File.join(dir, "baleen.txt")
      end
      @log = Logger.new(device)
      @log.level = config.log_level
    end

    def error(msg)
      instance.log.error(msg.red)
    end

    def self.warn(msg)
      instance.log.warn(msg.yellow)
    end

    def self.info(msg)
      instance.log.info(msg.green)
    end

    def self.debug(msg)
      instance.log.debug(msg.magenta)
    end

  end
end

