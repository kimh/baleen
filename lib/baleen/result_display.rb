require "colorize"

module Baleen
  class ResultDisplay
    def initialize(result, start_time, end_time, output)
      @result     = result
      @start_time = start_time
      @end_time   = end_time
      @output     = output
    end

    def report_result
      if @result
        summary
        detail
      end
    end

    def summary
      tests_result = pass_all? ? "Pass".blue : "Fail".red
      time = run_time

      @output.puts   ""
      @output.puts   "[Summary]".yellow
      @output.puts   "Result: ".yellow + tests_result
      @output.puts   "Time: ".yellow + time.green
      @output.puts   ""
    end

    def detail
      @output.puts "[Details]".yellow
      @result.each do |r|
        @output.puts "Id: ".yellow + "#{r['container_id']}".green
        @output.puts "status code: ".yellow + "#{r['status_code']}".green
        @output.puts "feature file: ".yellow + "#{r['file']}".green

        if r['stdout']
          @output.puts "STDOUT:".yellow
          @output.puts "------------------------------------".yellow
          @output.puts "#{r['stdout'].join}".green
        end

        if r['stderr']
          @output.puts "STDERR:".yellow
          @output.puts "------------------------------------".yellow
          @output.puts "#{r['stderr'].join}".red
        end
      end
    end

    private

    def pass_all?
      @result.all? {|r| r['status_code'] == 0}
    end

    def run_time
      diff = @end_time - @start_time
      min  = (diff / 60).floor
      sec  = min != 0 ? (diff - (min * 60)).floor : diff.floor
      "#{min}min #{sec}sec"
    end
  end
end