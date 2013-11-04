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
    include Celluloid::IO

    def initialize(socket, task)
      @socket     = socket
      @queue      = []
      @results    = []
      @task       = task
      @connection = Connection.new(socket)
    end

    def run
      prepare_task
      create_runners.each do |runners|
        @queue = runners
        @queue.each do |runner|
          runner.async.run
        end
        loop {break if monitor_runners}
        @results += @queue.map {|runner| runner.status}
      end
      @task.results = @results
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

    def monitor_runners
      @queue.all?{ |r| r.status }
    end
  end

  class Runner
    include Celluloid::IO

    extend Forwardable

    def_delegator :@connection, :respond

    Result = Struct.new("Result", :status_code, :container_id, :log)
    attr_reader :status

    def initialize(task, connection=nil)
      @container = Docker::Container.create('Cmd' => [task.shell, task.opt, task.commands], 'Image' => task.image)
      @status = nil
      @task = task
      @connection = connection
    end

    def run
      start_runner do |result|
        @status = {
           status_code: result.status_code,
           container_id: result.container_id,
           log: result.log,
           file: @task.files,
        }
      end
      sleep 0.1 # Stop a moment until RunnerManager checks the status
    end

    def result
      rst = @container.json
      log = @container.attach(:stream => false, :stdout => true, :stderr => true, :logs => true)

      Result.new(
        rst["State"]["ExitCode"],
        rst["ID"],
        log
      )
    end

    def start_runner
      max_retry = 3; count = 0

      begin

        respond("Start container #{@container.id}") if @connection
        @container.start
        @container.wait
        respond("Finish container #{@container.id}") if @connection

        if @task.commit
          info "Committing the change of container #{@container.id}"
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
      yield( result )
    end

  end
end