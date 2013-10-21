require_relative '../../spec_helper'

describe Baleen::ResultDisplay do
  describe "#summary" do
    context "when all test passes" do
      it "should display Pass" do
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
        displayer = Baleen::ResultDisplay.new(result, Time.now, Time.now+10)
        capture(:stdout) { displayer.summary }.should include 'Pass'
      end
    end

    context "when some test fails" do
      it "should display Fail" do
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
        displayer = Baleen::ResultDisplay.new(result, Time.now, Time.now+10)
        capture(:stdout) { displayer.summary }.should include 'Fail'
      end
    end
  end
end