require 'baleen/utils/colored_puts'

module Baleen
  module Message
    class Base

      include Serializable

      def initialize()
        @params = {}
        @params[:klass] = self.class.to_s
      end

    end
  end
end