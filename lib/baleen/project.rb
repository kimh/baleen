module Baleen
  class Project

      @@projects = {}

      attr_reader :config

      def self.projects(name=nil)
        if name
          @@projects[name.to_sym]
        else
          @@projects
        end
      end

      def self.load_project(config)
        if File.exists?(config)
          yaml = Baleen::Serializable.symbolize_keys(YAML.load_file(config))
        else
          colored_error "Config file not found"
          raise Baleen::Error::ConfigMissing
        end

        yaml.each do |project, cfg|
          if Baleen::Config::Validator.check(cfg)
            @@projects[project] = self.new(cfg)
          end
        end
      end

      def self.find_project(name, attribute, params={})
        projects = Baleen::Project.projects

        if name && attribute
          raise "You cannot specify name and attribute at the same time"
        elsif name
          return projects[name.to_sym]
        elsif attribute
          projects.each do |project, attributes|
            attributes.config.each do |attr, values|
              if attr == attribute
                params.each do |_k, _v|
                  return nil unless values[_k] == _v
                end
                return projects[project]
              end
            end
          end
        end
      end

      def self.find_project_by_name(name)
        find_project(name.to_sym, nil)
      end

      def self.find_project_by_github(params)
        find_project(nil, :github, params)
      end

      def self.find_project_by_runner(params)
        find_project(nil, :runner, params)
      end

      def self.find_project_by_framework(params)
        find_project(nil, :framework, params)
      end

      def initialize(cfg)
        load_config(cfg)
      end

      def load_config(cfg)
        if Baleen::Config::Validator.check(cfg)
          cfg[:runner][:before_command] ||= default_before_command
          cfg[:runner][:concurrency]    ||= default_concurrency
          cfg[:runner][:work_dir]       ||= default_work_dir
          cfg[:runner][:image]

          case cfg[:framework][:type]
            when "cucumber"
              cfg[:framework][:files] = cfg[:framework][:features] || default_features
            else
              raise "Passed unknown framework from config yml: #{cfg[:framework][:type]}"
          end
        end
        @config = cfg
      end

      def github
        @config[:github]
      end

      def task
        Baleen::Task::Cucumber.new(
          image: @config[:runner][:image],
          work_dir: @config[:runner][:work_dir],
          files: @config[:framework][:files],
          before_command: @config[:runner][:before_command],
          concurrency: @config[:runner][:concurrency].to_i,
        )
      end
  end
end