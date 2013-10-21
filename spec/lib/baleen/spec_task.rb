require_relative '../../spec_helper'

include Baleen::Task

describe Baleen::Task do

  describe Generic do
    it "executes command" do
      string = "OK"
      task = Baleen::Task::Generic.new(
        image: base_image,
        command: "echo #{string}",
      )
      runner = Baleen::Runner.new(task)
      result = runner.run
      expect(result[:log]).to include string
    end
  end

  describe Cucumber do
    it "runs cucumber test" do
      task = Baleen::Task::Cucumber.new(
        image: base_image,
        work_dir: "/poc",
        files: "features/t0.feature",
        before_command: "source /etc/profile",
        concurrency: 1,
      )
      runner = Baleen::Runner.new(task)
      result = runner.run
      expect(result[:log]).to include "Scenario"
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

      runner = Baleen::Runner.new(task)
      runner.run
      @image = Docker::Image.build("from #{test_image}")
      after_id = @image.json["id"]

      expect(after_id).not_to eq(before_id)
    end
  end

end
