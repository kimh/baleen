require_relative '../../spec_helper'

include Baleen::Validator

describe Baleen::Validator do
  describe Baleen::Validator::Cucumber do
    it "should validate allowed attributes" do
      config = {
        :framework=>"cucumber",
        :baleen_server=>"127.0.0.1",
        :image=>"kimh/baleen-poc",
        :features=>"./features",
        :work_dir=>"./",
        :concurrency=>3,
        :before_commands=>"source /profile"
      }
      expect(Baleen::Validator::Validator.check(config)).to be_true
    end

    it "should invalidate dis-allowed attributes" do
      config = {
        :framework=>"cucumber",
        :bad =>"MJ",
      }
      expect(Baleen::Validator::Validator.check(config)).to be_false
    end

    it "should raise Baleen::Error::Validator::FrameworkMissing" do
      config = {
        :baleen_server=>"127.0.0.1",
        :image=>"kimh/baleen-poc",
        :features=>"./features",
        :work_dir=>"./",
        :concurrency=>3,
        :before_commands=>"source /profile"
      }
      expect{Baleen::Validator::Validator.check(config)}.to raise_error Baleen::Error::Validator::FrameworkMissing
    end

    it "should raise Baleen::Error::Validator::MandatoryMissing" do
      config = {
        :framework=>"cucumber",
        :image=>"kimh/baleen-poc",
        :features=>"./features",
      }
      expect{Baleen::Validator::Validator.check(config)}.to raise_error Baleen::Error::Validator::MandatoryMissing
    end
  end
end