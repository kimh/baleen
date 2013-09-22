require "colorize"

module Kernel
  private

  def info(msg)
    puts msg.green
  end

  def notice(msg)
    puts msg.yellow
  end

  def warning(msg)
    puts msg.red
  end
end
