require "rspec"
require File.expand_path('../../lib/baleen.rb', __FILE__)

def test_image
  ENV["test_image"] ||= "baleen/tester"
end
