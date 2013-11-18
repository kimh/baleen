require "colorize"

module Kernel
  private

  def hl_info(msg)
    puts msg.green
  end

  def hl_warn(msg)
    puts msg.yellow
  end

  def hl_error(msg)
    puts msg.red
  end
end
