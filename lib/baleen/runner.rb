require "baleen/error"
require 'forwardable'

module Baleen

  class Connection
    def initialize(socket)
      @socket = socket
    end

    def respond(msg)
      response = Baleen::Task::Response.new({:message => msg})
      @socket.puts(response.to_json)
    end
  end

  class RunnerManager
    def initialize(socket, task)
      @socket     = socket
      @task       = task
      @connection = Connection.new(socket)
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
      @task.status = "done"
      @socket.puts(@task.to_json)
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

    def_delegator :@connection, :respond

    def initialize(task, connection=nil)
      @container = Docker::Container.create('Cmd' => [task.shell, task.opt, task.commands], 'Image' => task.image)
      @task = task
      @connection = connection
    end

    def run
      max_retry = 3; count = 0

      begin
        respond("Start container #{@container.id}") if @connection
        @container.start
        @container.wait
        respond("Finish container #{@container.id}") if @connection

        if @task.commit
          respond("Committing the change of container #{@container.id}") if @connection
          @container.commit({repo: task.image}) if @task.commit
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