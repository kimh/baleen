require "baleen/error"
require 'forwardable'

module Baleen

  class RunnerManager
    def initialize(connection, task)
      @task       = task
      @connection = connection
    end

    def run
      results = []
      prepare_task
      create_runners.each do |runners|
        runners.map{|runner| runner.future.run}.each do |actor|
          results << actor.value
        end
      end
      @task.results = results
      yield @task
    end

    private

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
      @container = Docker::Container.create('Cmd' => [task.shell, task.opt, task.commands], 'Image' => task.image)
      @connection = connection ? connection : Connection.new
      @task = task
    end

    def run
      max_retry = 3; count = 0

      begin
        notify_info("Start container #{@container.id}")
        @container.start
        @container.wait
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

      return {
        status_code: @container.json["State"]["ExitCode"],
        container_id: @container.id,
        log: @container.attach(:stream => false, :stdout => true, :stderr => true, :logs => true),
        file: @task.files,
      }
    end

  end
end