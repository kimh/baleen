module Baleen
  module Task
    class Base
      include Serializable

      def initialize
        @params = {}
        @params[:klass]          = self.class.to_s
        @params[:shell]          = nil
        @params[:opt]            = nil
        @params[:work_dir]       = nil
        @params[:files]          = nil
        @params[:exe]            = nil
        @params[:concurrency]    = nil
        @params[:image]          = nil
        @params[:before_command] = nil
        @params[:command]        = nil
        @params[:results]        = nil
        @params[:status]         = nil
        @params[:commit]         = nil
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

      def result
        @params[:results]
      end

    end
  end
end


