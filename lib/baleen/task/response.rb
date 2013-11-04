require "baleen/task/base"

module Baleen
  module Task
    class Response < Base
      def initialize(opt)
        super()
        @params[:message]        = opt[:message]
      end
    end
  end
end