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
        Runner.new(task)
      }.each_slice(@task.concurrency).map {|r| r}
    end

    def monitor_runners
      @queue.all?{ |r| r.status }
    end
  end

  class Runner
    include Celluloid::IO

    attr_reader :status

    def initialize(task)
      @docker_client = Container::DockerClient.new
      @status = nil
      @task = task
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

    def start_runner
      max_retry = 3; count = 0

      begin
        @docker_client.start_container(@task)
      rescue Excon::Errors::NotFound => e
        count += 1
        if count > max_retry
          raise Baleen::Error::StartContainerFail
        else
          retry
        end
      end
      yield( @docker_client.result )
    end

  end
end