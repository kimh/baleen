require "json"
require "baleen/message/base"

module Baleen
  module Message
    module Request

      class ClientDisconnect < Base
        def initialize(opt = {}); super() end
      end

      class Cucumber < Base
        def initialize(image: nil, work_dir: "./", files: "features", shell: "/bin/bash", opt: "-c", exe: "bundle exec cucumber", before_command: nil, command: nil, concurrency: 2)
          super()
          @params[:image]          = image
          @params[:shell]          = shell
          @params[:opt]            = opt
          @params[:work_dir]       = work_dir
          @params[:files]          = files
          @params[:exe]            = exe
          @params[:before_command] = before_command
          @params[:command]        = command
          @params[:concurrency]    = concurrency
        end
      end

    end
  end
end