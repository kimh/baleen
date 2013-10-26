# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baleen/version'

Gem::Specification.new do |spec|
  spec.name          = "baleen"
  spec.version       = Baleen::VERSION
  spec.authors       = ["Kim, Hirokuni"]
  spec.email         = ["kimh@kvh.co.jp"]
  spec.description   = %q{Ballen allows you to run standard ruby tests in parallel and isolated environment}
  spec.summary       = %q{Container-based parallel test runner powered by Docker}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "interactive_editor"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency 'celluloid'
  spec.add_runtime_dependency 'celluloid-io'
  spec.add_runtime_dependency 'docker-api'
  spec.add_runtime_dependency 'colorize'
  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'sinatra'

end

