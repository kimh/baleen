require_relative '../../spec_helper'

describe "serialization" do
  context Baleen::Task::Generic do
    it "should be serializable" do
      task = Baleen::Task::Generic.new({})
      json = task.to_json
      deserialized = Baleen::Serializable.deserialize(json)

      expect(deserialized.class).to eq Baleen::Task::Generic
    end

  end

  context Baleen::Task::Cucumber do
    it "should be serializable" do
      task = Baleen::Task::Cucumber.new({})
      json = task.to_json
      deserialized = Baleen::Serializable.deserialize(json)

      expect(deserialized.class).to eq Baleen::Task::Cucumber
    end
  end

  context Baleen::Task::ImageUpdate do
    it "should be serializable" do
      task = Baleen::Task::ImageUpdate.new({})
      json = task.to_json
      deserialized = Baleen::Serializable.deserialize(json)

      expect(deserialized.class).to eq Baleen::Task::ImageUpdate
    end
  end

  context Baleen::Message::ToClient do
    it "should be serializable" do
      task = Baleen::Message::ToClient.new({})
      json = task.to_json
      deserialized = Baleen::Serializable.deserialize(json)

      expect(deserialized.class).to eq Baleen::Message::ToClient
    end
  end

end