require "rspec"
require File.expand_path('../../lib/baleen.rb', __FILE__)

def base_image
  ENV["test_base"] ||= "baleen/test_base"
end

def test_image
  example.description.gsub("\s", "-")
end

def poc_tar
  "poc.tar.gz"
end

def poc_tar_path
  File.expand_path("../#{poc_tar}", __FILE__)
end
