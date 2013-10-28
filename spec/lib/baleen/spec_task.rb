require_relative '../../spec_helper'

include Baleen::Container

describe Baleen::Task::Generic do

  before :each do
    Docker.url = "http://192.168.56.4:4243"
    @docker_client = DockerClient.new
  end

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

describe Baleen::Task::ImageUpdate do

  before :all do
    Docker.url = "http://192.168.56.4:4243"
    @docker_client = DockerClient.new
  end

  before :each do
    @image = Docker::Image.build("from #{base_image}")
    @image.tag('repo' => test_image, 'force' => true)
  end

  after :each do
    @new_image.remove if @new_image
  end

  it "commit changes" do
    before_id = @image.json["id"]
    task = Baleen::Task::ImageUpdate.new(
      image: test_image,
      command: "touch ./new_file.txt",
    )

    @docker_client.start_container(task)
    @new_image = Docker::Image.build("from #{test_image}")
    after_id = @new_image.json["id"]

    expect(after_id).not_to eq(before_id)
  end
end
