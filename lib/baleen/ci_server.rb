require 'sinatra/base'
require 'docker'
require 'baleen'

module Baleen
  class CiServer < Sinatra::Base

    include Celluloid::IO
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
      project = Baleen::Project.find_project_by_ci({repo: repo, branch: branch})

      if project
        async.ci_run(project)
      end
    end

    private

    def ci_run(project)
      if project.ci[:build]
        builder = Baleen::Builder.new(project, Docker.url)
        builder.build
      end

      RunnerManager.new(nil, project.task).run do |response|
        puts "------ DEBUG START -------"
          require "pp"
          load "/Users/kimh/.rvm/gems/ruby-1.9.3-p286@nice/gems/awesome_print-1.2.0/lib/awesome_print.rb"
          ap response
        puts "-------DEBUG END   -------"
      end
    end
  end
end
