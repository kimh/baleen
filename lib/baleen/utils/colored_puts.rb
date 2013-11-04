require "colorize"

module Kernel
  private

  def colored_info(msg)
    puts msg.green
  end

  def colored_warn(msg)
    puts msg.yellow
  end

  def colored_error(msg)
    puts msg.red
  end
end
