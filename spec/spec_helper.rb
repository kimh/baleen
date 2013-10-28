require "rspec"
require File.expand_path('../../lib/baleen.rb', __FILE__)

def base_image
  ENV["test_base"] ||= "baleen/test_base"
end

def test_image
  example.description.gsub("\s", "-")
end
