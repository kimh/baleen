require "rspec"
require 'vcr'
require 'webmock'
require File.expand_path('../../lib/baleen.rb', __FILE__)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true  #VCRブロック外のHTTP通信は許可する
  c.hook_into :webmock # or :fakeweb
end
