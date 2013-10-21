require_relative '../../spec_helper'

include Baleen::Config

describe Baleen::Config do
  context "when all mandatory attributes are given" do
    it "should pass the check" do
      config = {
        :base => {
          :baleen_server=>"127.0.0.1",
        },
        :runner => {
          :image=>"kimh/baleen-poc",
        },
        :framework => {
          :type => "cucumber"
        }
      }
      expect(Baleen::Validation::Validator.check(config)).to be_true
    end
  end

  context "when invalid attributes are given" do
    it "should not pass the check" do
      config = {
        :base => {
          :baleen_server=>"127.0.0.1",
        },
        :runner => {
          :image=>"kimh/baleen-poc",
        },
        :framework => {
          :type => "cucumber",
          :bad =>"MJ", # This is invalid
        }
      }
      expect(Baleen::Validation::Validator.check(config)).to be_false
    end
  end

  context "when mandatory attributes are not given" do
    it "should raise Baleen::Error::Validator::MandatoryMissing" do
      config = {
        :base => {
          #:baleen_server is missing
          :port=>5533,
        }
      }
      expect{Baleen::Validation::Validator.check(config)}.to raise_error Baleen::Error::Validator::MandatoryMissing
    end
  end

end