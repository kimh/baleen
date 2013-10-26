require_relative '../../spec_helper'

include Baleen::Container

describe Baleen::Container::DockerClient do
  before :all do
    @task = Baleen::Task::Request::Cucumber.new(
      image: "kimh/baleen-poc",
      work_dir: "/git/baleen/poc",
      files: "./",
      before_command: "source /etc/profile",
      concurrency: 2,
      commit: false
    )
  end

  before :each do
    Docker.url = "http://192.168.56.4:4243"
    VCR.use_cassette('start_container') do
      @docker_client = DockerClient.new
      @docker_client.start_container(@task)
    end
  end

  it "must start container" do
    VCR.use_cassette('start_container') do
      expect(@docker_client.result).not_to be_nil
    end
  end

end