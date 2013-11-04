require "baleen/error"

module Baleen

  class RunnerManager
    include Celluloid::IO

    def initialize(socket, task)
      @socket     = socket
      @queue      = []
      @results    = []
      @task       = task
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
        Runner.new(task, @socket)
      }.each_slice(@task.concurrency).map {|r| r}
    end

    def monitor_runners
      @queue.all?{ |r| r.status }
    end
  end

  class Runner
    include Celluloid::IO

    Result = Struct.new("Result", :status_code, :container_id, :log)
    attr_reader :status

    def initialize(task, socket=nil)
      @container = Docker::Container.create('Cmd' => [task.shell, task.opt, task.commands], 'Image' => task.image)
      @status = nil
      @task = task
      @socket = socket
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
        info "Start container #{@container.id}"
        @container.start
        @container.wait
        info "Finish container #{@container.id}"

        res = Baleen::Task::Response.new({:message => "AAAAAAA"})
        @socket.puts(res.to_json) if @socket

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