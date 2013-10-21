require 'sinatra/base'
require 'docker'
require 'baleen'

module Baleen
  class GitHook < Sinatra::Base

    def self.run!(params={})
      docker_host = params[:docker_host]
      docker_port = params[:docker_port]
      Docker.url  = "http://#{docker_host}:#{docker_port}"

      set :port, params[:port]
      set :environment, :production
      super
    end

    post '/' do
      task = Baleen::Task::ImageUpdate.new(
        image: "kimh/baleen-poc",
        command: "git pull",
        work_dir: "/git/baleen/poc",
      )
      runner = Baleen::Runner.new(task)
      runner.run
    end
  end
end