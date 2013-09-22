require 'json'

module Baleen
  module Message
    module Response

      class RunnerFinish < Base

        def initialize(opt = {})
          super()
          @params[:status_code]   = opt[:status_code]
          @params[:log ]          = opt[:log]
          @params[:container_id ] = opt[:container_id]
          @params[:file]          = opt[:file]
        end
      end

      class JobComplete < Base
        include Baleen::Message

        def initialize(opt = {})
          super()
          @params[:status]  = opt[:status]
          @params[:results] = opt[:results]
        end

        def result
          JSON.parse(@params[:results]).map {|r| symbolize_keys(r) }
        end
      end

    end
  end
end