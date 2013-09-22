require "baleen/error"

module Baleen

  class DockerParam
    def initialize(params)
      @params = params
    end

    def method_missing(name, *args)
      DockerParam.class_eval{
        define_method "#{name}" do
          @params[name.to_sym]
        end

        define_method "#{name}=" do |*args|
          @params[name.to_sym] = args.first
        end
      }
      send(name)
    end

    def commands
      %{
        #{@params[:before_command]}
        cd #{@params[:work_dir]}
        #{command}
      }
    end

    def command
      @params[:command] ||= %{#{@params[:exe]} #{@params[:files]}}
    end

    def command=(c)
      @params[:command] = c
    end

    def dup
      copy_params = @params.dup
      Object.const_get(self.class.to_s).new(copy_params)
    end
  end

  class RunnerManager
    include Celluloid::IO

    CONCURRENCY=2

    def initialize(socket, msg)
      @socket     = socket
      @queue      = []
      @results    = []
      @params     = DockerParam.new(msg.params)
    end

    def run
      create_runners.each do |runners|
        @queue = runners
        @queue.each do |runner|
          runner.async.run
        end
        loop {break if monitor_runners}
        @results += @queue.map {|runner| runner.status.params}
      end
      msg = Message::Response::JobComplete.new(status: "done", results: @results.to_json)
      @socket.puts(msg.to_json)
    end

    private

    def create_runners
      target_files.map {|file|
        params = @params.dup
        params.files = file
        Runner.new(params)
      }.each_slice(@params.concurrency).map {|r| r}
    end

    def target_files
      params = @params.dup
      params.command = %{find #{params.files} | grep "\\.feature"}
      runner = Runner.new(params)
      runner.run
      runner.status.log.split("\n")
    end

    def monitor_runners
      @queue.all?{ |r| r.status }
    end
  end

  class Runner
    include Celluloid::IO

    attr_reader :status

    def initialize(params)
      @docker_client = Container::DockerClient.new
      @status = nil
      @params = params
    end

    def run
      start_runner do |result|
        @status = Message::Response::RunnerFinish.new(
           status_code: result.status_code,
           container_id: result.container_id,
           log: result.log,
           file: @params.files,
         )
      end
      sleep 0.1 # Stop a moment until RunnerManager checks the status
    end

    def start_runner
      max_retry = 3; count = 0

      begin
        @docker_client.create_container(@params)
        @docker_client.start_container
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