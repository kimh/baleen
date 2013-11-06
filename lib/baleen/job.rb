require 'baleen/result_display'

module Baleen
  class Job
    include Celluloid::IO

    def initialize(client, msg)
      @client = client
      @msg = msg
      @response = nil
    end

    def start
      start_time = Time.now
      @client.request(@msg.params)
      @response = @client.wait_response
      end_time = Time.now
      show_results(start_time, end_time)
    end

    private

    def show_results(s_time, e_time)
      display = ResultDisplay.new(@response.results, s_time, e_time)
      display.summary
      display.detail
    end

  end

end