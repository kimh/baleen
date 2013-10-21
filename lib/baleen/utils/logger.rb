require 'singleton'
require 'colorize'
require 'logger'

module Baleen

  # End of Log
  class EoL
    def initialize(proc)
      @proc = proc
    end

    def eol
      @proc.call
    end
  end

  ERROR   = Logger::ERROR
  WARN    = Logger::WARN
  INFO    = Logger::INFO
  DEBUG   = Logger::DEBUG

  class BL
    include Singleton

    attr_reader :log

    def initialize
      config = Baleen::Configuration.instance

      if config.debug == DEBUG
        device = STDOUT
      else
        dir = File.join(config.dir, "log")
        FileUtils.mkdir_p dir
        device = File.join(dir, "baleen.log")
        Celluloid.logger = nil
      end
      @log = Logger.new(device)
      @log.level = config.log_level
    end

    def self.error(msg)
      instance.log.error(msg.red)
      EoL.new(Proc.new{instance.log.error("")})
    end

    def self.warn(msg)
      instance.log.warn(msg.yellow)
      EoL.new(Proc.new{instance.log.warn("")})
    end

    def self.info(msg)
      instance.log.info(msg)
      EoL.new(Proc.new{instance.log.info("")})
    end

    def self.debug(msg)
      instance.log.debug(msg.magenta)
      EoL.new(Proc.new{instance.log.debug("")})
    end

    def self.notice(msg)
      instance.log.info(msg.green)
      EoL.new(Proc.new{instance.log.info("")})
    end

    def puts(msg)
      log.info(msg)
    end

  end
end

