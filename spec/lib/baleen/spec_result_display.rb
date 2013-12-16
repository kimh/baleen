require_relative '../../spec_helper'

describe Baleen::ResultDisplay do
  describe "#summary" do
    context "when all test passes" do
      result = [
        {
          "status_code" => 0,
          "container_id" => "aaaaaa",
          "log" => "brabrabra",
          "file" => "feature/t1.feature"
        },
        {
          "status_code" => 0,
          "container_id" => "bbbbbb",
          "log" => "brabrabra",
          "file" => "feature/t2.feature"
        }
      ]

      context "when output is STDOUT" do
        it "should display Pass" do
          displayer = Baleen::ResultDisplay.new(result, Time.now, Time.now+10, Kernel)
          capture(:stdout) { displayer.summary }.should include 'Pass'
        end
      end

      context "when output is logger" do
        it "should contain Pass" do
          logger = Baleen::BL.instance
          log_file = File.join(Baleen::Configuration.instance.dir, "log", "baleen.log")

          Baleen::ResultDisplay.new(result, Time.now, Time.now+10, logger).summary
          expect(File.open(log_file).read).to include 'Pass'
        end
      end

    end

    context "when some test fails" do
      result = [
         {
           "status_code" => 0,
           "container_id" => "aaaaaa",
           "log" => "brabrabra",
           "file" => "feature/t1.feature"
         },
         {
           "status_code" => 1,
           "container_id" => "bbbbbb",
           "log" => "brabrabra",
           "file" => "feature/t2.feature"
         }
      ]

      context "when output is STDOUT" do
        it "should display Fail" do
          displayer = Baleen::ResultDisplay.new(result, Time.now, Time.now+10, Kernel)
          capture(:stdout) { displayer.summary }.should include 'Fail'
        end
      end

      context "when output is logger" do
        it "should contain Pass" do
          logger = Baleen::BL.instance
          log_file = File.join(Baleen::Configuration.instance.dir, "log", "baleen.log")

          Baleen::ResultDisplay.new(result, Time.now, Time.now+10, logger).summary
          expect(File.open(log_file).read).to include 'Fail'
        end
      end

    end

  end
end