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
      loop {
         @response = @client.wait_response
         puts "------ DEBUG START -------"
           require "pp"
           load "/Users/kimh/.rvm/gems/ruby-1.9.3-p286@nice/gems/awesome_print-1.2.0/lib/awesome_print.rb"
           ap @response
         puts "-------DEBUG END   -------"
        if @response.class == Baleen::Task::Request::Cucumber
          puts "done"
          break
        end

      }
      end_time = Time.now
      show_results(start_time, end_time)
    end

    private

    def show_results(s_time, e_time)
      display = ResultDisplay.new(@response.results, start_time: s_time, end_time: e_time)
      display.summary
      display.detail
    end

  end

end