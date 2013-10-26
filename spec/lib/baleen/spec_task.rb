require_relative '../../spec_helper'

include Baleen::Container
include Baleen::Task

describe Baleen::Task do

  before :all do
    @docker_client = DockerClient.new
  end

  describe Generic do
    it "executes command" do
      string = "OK"
      task = Baleen::Task::Generic.new(
        image: base_image,
        command: "echo #{string}",
      )
      @docker_client.start_container(task)
      expect(@docker_client.result.log).to include string
    end
  end

  describe Request::Cucumber do
    it "runs cucumber test" do
      task = Baleen::Task::Request::Cucumber.new(
        image: base_image,
        work_dir: "/poc",
        files: "features/t0.feature",
        before_command: "source /etc/profile",
        concurrency: 1,
      )
      @docker_client.start_container(task)
      expect(@docker_client.result.log).to include "Scenario"
    end
  end

  describe ImageUpdate do
    before :each do
      Docker::Image.all.each do |i|
        if i.json["container_config"]["Image"] == test_image
          i.remove
        end
      end
      @image = Docker::Image.build("from #{base_image}")
      @image.tag('repo' => test_image, 'force' => true)
    end

    it "commit changes" do
      before_id = @image.json["id"]
      task = Baleen::Task::ImageUpdate.new(
        image: test_image,
        command: "touch ./new_file.txt",
      )

      @docker_client.start_container(task)
      @image = Docker::Image.build("from #{test_image}")
      after_id = @image.json["id"]

      expect(after_id).not_to eq(before_id)
    end
  end

end
