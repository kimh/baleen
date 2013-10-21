module Baleen
  module Container

    class DockerClient
      Result = Struct.new("Result", :status_code, :container_id, :log)

      def start_container(params)
        @container = Docker::Container.create('Cmd' => [params.shell, params.opt, params.commands], 'Image' => params.image)

        info "Start container #{@container.id}"
        @container.start
        @container.wait
        info "Finish container #{@container.id}"

        if params.commit
          info "Committing the change of container #{@container.id}"
          @container.commit({repo: params.image}) if params.commit
        end
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