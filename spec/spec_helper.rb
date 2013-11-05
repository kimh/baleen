require "rspec"
require File.expand_path('../../lib/baleen.rb', __FILE__)

RSpec.configure do |config|
  unless Docker.url = ENV["docker_url"]
    error "You have to set 'docker_url' environment variable before running test
    Ex: export docker_url=\"http://192.168.56.4:4243\""
    exit 1
  end
end

def base_image
  ENV["test_base"] ||= "baleen/test_base"
end

def test_image
  "baleen/#{example.description.gsub("\s", "-")}"
end
