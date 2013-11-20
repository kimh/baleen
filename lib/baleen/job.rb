require 'baleen/result_display'

module Baleen
  class Job

    def initialize(client, msg)
      @client = client
      @msg = msg
      @response = nil
    end

    def start
      start_time = Time.now
      @client.request(@msg.params)
      @response = @client.wait_response

      unless @response.nil?
        end_time = Time.now
        show_results(start_time, end_time)
      end
    end

    private

    def show_results(s_time, e_time)
      display = ResultDisplay.new(@response.results, s_time, e_time, STDOUT)
      display.report_result
    end

  end

end