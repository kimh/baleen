require 'baleen/utils/colored_puts'

module Baleen
  module Message
    class Base

      include Serializable

      def initialize()
        @params = {}
        @params[:klass] = self.class.to_s
      end

      def results
        nil
      end

      def terminate?
        false
      end

    end
  end
end