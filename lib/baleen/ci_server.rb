require 'sinatra/base'
require 'docker'
require 'baleen'

module Baleen
  class CiServer < Sinatra::Base

    include Celluloid::IO
    include Baleen
    extend Baleen::Default

    def self.run!(params={})
      docker_host  = params[:docker_host]
      docker_port  = params[:docker_port]
      project_file = params[:project_file] || default_project_file
      log_level    = params[:log_level]    || default_log_level

      Docker.url  = "http://#{docker_host}:#{docker_port}"
      Baleen::Project.load_project(project_file)
      Baleen::Configuration.log_level = log_level

      set :port, params[:port]
      set :environment, :production
      super
    end

    post '/' do
      payload = JSON.parse(params[:payload])
      repo    = payload["repository"]["name"]
      branch  = payload["ref"].split("/").last
      project = Baleen::Project.find_project_by_ci({repo: repo, branch: branch})
      BL.notice("Receiving post receive hook for #{project.url}").eol

     if project
        async.ci_run(project)
      end
    end

    private

    def ci_run(project)
      BL.notice("CI started")
      BL.info(" Project: #{project.name}")
      BL.info(" Repo:    #{project.repo}")
      BL.info(" Branch:  #{project.branch}").eol

      if project.ci[:build]
        BL.notice("Building new image for #{project.image} before running tests...")
        result = Baleen::Builder.new(project, Docker.url).build
        BL.info (result)
      end

      BL.notice("Start running tests...")
      RunnerManager.new(nil, project.task).run do |response|
        logger  = Baleen::BL.instance
        display = ResultDisplay.new(response.results, Time.now, Time.now, logger)
        display.summary
        display.detail
      end
      BL.notice("Finish running tests...").eol
    end
  end
end
