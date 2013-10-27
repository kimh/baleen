require_relative '../../spec_helper'

include Baleen::Container

describe Baleen::Container::DockerClient do

  before :each do
    Docker.url = "http://192.168.56.4:4243"
    @docker_client = DockerClient.new
  end

  it "executes command" do
    string = "OK"
    task = Baleen::Task::Generic.new(
      image: test_image,
      command: "echo #{string}",
    )
    @docker_client.start_container(task)
    expect(@docker_client.result.log).to include string
  end

  #it "commits change" do

  #  task = Baleen::Task::ImageUpdate.new(
  #    image: "kimh/baleen-poc",
  #    command: "touch new_file.txt",
  #    commit: true
  #  )
  #  before = @docker_client.container_id
  #  @docker_client.start_container(task)
  #  after  = @docker_client.container_id

  #end


end