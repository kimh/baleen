require 'sinatra/base'
require 'docker'
require 'baleen'

module Baleen
  class GitHook < Sinatra::Base


    def self.run!(params={})
      docker_host = params[:docker_host]
      docker_port = params[:docker_port]
      config      = params[:config] || File.join(ENV["HOME"], "baleen.yml")

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
      project = Baleen::Project.find_project_by_github({repo: repo})
      builder = Baleen::Builder.new(project)
      builder.build
    end
  end
end