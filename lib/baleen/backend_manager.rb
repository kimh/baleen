require "baleen/error"

module Baleen


  class BackendManager

    attr_reader :alias

    def initialize(project)
      @task    = project.task
      @image   = project.backend_image
      @alias   = project.backend_alias
      @command = project.backend_command
      @pool = []
   end

    def start_containers
      @containers = @task.concurrency.times.map {
        Docker::Container.create('Cmd' => ["bash", "-c", @command], 'Image' => @image).start
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