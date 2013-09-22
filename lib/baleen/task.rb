module Baleen
  module Task

    class Command
      def initialize(work_dir, files, bundler)
        @work_dir = work_dir
        @files = files
        @bundler = bundler
        @before = []
        build_default_arg
      end

      def before(commands=nil)
        commands = sanitize_and_tokenize(commands) if commands
        commands ? @before = commands : @before
      end

      def commands
        @before ? @before + @args : @args
      end

      def <<(arg)
        @args << arg
      end

      private

      def build_default_arg
        exe = @bundler ? "bundle exec cucumber" : "cucumber"
        @args = ["cd #{@work_dir}", "#{exe} #{@files}"]
      end

      def sanitize_and_tokenize(arg)
        # sanitize
        arg = arg.strip.gsub(/^ */, '').gsub(/\n+/, "\n")
        # tokenize
        arg = arg.gsub(";", "\n")
        arg.split("\n")
      end
    end

  end
end

