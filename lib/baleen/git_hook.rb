require 'sinatra/base'
require 'docker'
require 'baleen'

module Baleen
  class GitHook < Sinatra::Base

    extend Baleen::Default

    def self.run!(params={})
      docker_host = params[:docker_host]
      docker_port = params[:docker_port]
      config      = params[:config] || default_config

      Docker.url  = "http://#{docker_host}:#{docker_port}"
      Baleen::Project.load_project(config)

      set :port, params[:port]
      set :environment, :production
      super
    end

    post '/' do
      payload = JSON.parse(params[:payload])
      repo    = payload["repository"]["name"]
      branch  = payload["ref"].split("/").last
      project = Baleen::Project.find_project_by_github({repo: repo, branch: branch})

      if project
        builder = Baleen::Builder.new(project, Docker.url)
        builder.build
      end
    end
  end
end
