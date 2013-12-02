module Baleen
  module Default

    def default_baleen_server
      "127.0.0.1"
    end

    def default_port
      5533
    end

    def default_dir
      "./baleen"
    end

    def default_concurrency
      2
    end

    def default_before_command
      nil
    end

    def default_features
      "./features"
    end

    def default_work_dir
      "./"
    end

    def default_docker_host
      "127.0.0.1"
    end

    def default_docker_port
      4243
    end

    def default_ci_port
      4567
    end

    def default_project_file
      File.join(ENV["HOME"], "baleen.yml")
    end

    def default_branch
      "master"
    end

    def default_log_level
      Baleen::INFO
    end

    def default_daemon
      false
    end

  end
end