require "baleen/error"

module Baleen
  class BackendService
    def initialize(task)
      @task = task
      @pool = []
   end

    def start_containers
      @containers = @task.concurrency.times.map {
        Docker::Container.create('Cmd' => ["bash", "-c", "env && tail -f /dev/null"], 'Image' => "base").start
      }
    end

    def fetch_container
      @pool = @containers.dup if @pool.empty?
      @pool.pop
    end

    def stop_containers
      @containers.each {|c| c.kill}
    end
  end
end