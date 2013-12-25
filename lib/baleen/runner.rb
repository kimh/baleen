require "baleen/error"
require 'forwardable'

module Baleen

  class RunnerManager
    def initialize(connection, task, backend=nil)
      @task       = task
      @connection = connection
      @backend    = backend
    end

    def start
      prepare_task
      runners = create_runners
      @task.results = @backend ? run_with_backend(runners) : run(runners)
      yield @task
    end

    private

    def run(runners_group)
      results = []
      runners_group.each do |runners|
        runners.map{|runner|
          runner.future.run
        }.each do |actor|
          results << actor.value
        end
      end
      results
    end

    def run_with_backend(runners_group)
      @backend.start_containers
      results = []
      runners_group.each do |runners|
        runners.map{|runner|
          runner.tap{|r| r.link_container(@backend.fetch_container, @backend.alias)}.future.run
        }.each do |actor|
          results << actor.value
        end
      end
      @backend.stop_containers
      results
    end

    def prepare_task
      @task.prepare
    end

    def create_runners
      @task.target_files.map {|file|
        task = @task.dup
        task.files = file
        Runner.new(task, @connection)
      }.each_slice(@task.concurrency).map {|r| r}
    end

  end

  class Runner
    include Celluloid
    extend Forwardable

    def_delegator :@connection, :notify_info

    def initialize(task, connection=nil)
      @container  = Docker::Container.create('Cmd' => ["bash", "-c", task.commands], 'Image' => task.image)
      @connection = connection ? connection : Connection.new
      @task = task
      @opt = {}
    end

    def run
      max_retry = 3; count = 0

      begin
        notify_info("Start container #{@container.id}")
        @container.start(@opt)
        @container.wait(600) #TODO move to configuration
        notify_info("Finish container #{@container.id}")

        if @task.commit
          notify_info("Committing the change of container #{@container.id}")
          @container.commit({repo: @task.image}) if @task.commit
        end
      rescue Excon::Errors::NotFound => e
        count += 1
        if count > max_retry
          raise Baleen::Error::StartContainerFail
        else
          retry
        end
      end

      stdout, stderr = *@container.attach(:stream => false, :stdout => true, :stderr => true, :logs => true)

      return {
        status_code: @container.json["State"]["ExitCode"],
        container_id: @container.id,
        stdout: stdout,
        stderr: stderr,
        file: @task.files,
      }
    end

    def link_container(container, alias_name)
      name = container.json["Name"][1..-1]
      @opt.merge!({'Links' => ["#{name}:#{alias_name}"]})
    end

  end
end