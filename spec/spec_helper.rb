require "rspec"
require 'stringio'
require File.expand_path('../../lib/baleen.rb', __FILE__)

RSpec.configure do |config|
  unless Docker.url = ENV["docker_url"]
    hl_error "You have to set 'docker_url' environment variable before running test
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

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval "$#{stream} = #{stream.upcase}"
  end
  result
end
