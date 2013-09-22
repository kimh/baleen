module Baleen
  module Container

    class DockerClient
      Result = Struct.new("Result", :status_code, :container_id, :log)

      def create_container(params)
        @container = Docker::Container.create('Cmd' => [params.shell, params.opt, params.commands], 'Image' => params.image)
      end

      def start_container
        info "Start container #{@container.id}"
        @container.start
        @container.wait
        info "Finish container #{@container.id}"
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

    end

  end
end