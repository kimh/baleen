module Baleen
  module Default

    def default_port
      5533
    end

    def default_baleen_server
      "127.0.0.1"
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
  end
end