require "find"
require "excon"
require "rubygems/package"

module Baleen
  class Builder

    def initialize(project)
      @project = project
    end

    def build
      url        = @project.github[:url]
      repo       = @project.github[:repo]
      tmp_dir    = "tmp/build"
      dir        = File.join(tmp_dir, repo)
      output     = StringIO.new
      connection = Excon.new('http://192.168.56.4:4243')

      FileUtils.mkdir_p(tmp_dir)

      if File.exists?(dir)
        Dir::chdir(dir)
        `git pull`
      else
        `git clone #{url} #{dir}`
        Dir::chdir(dir)
      end

      Gem::Package::TarWriter.new(output) do |tar|
        Find.find("./") do |f|
          if File::ftype(f) == "directory"
            tar.mkdir(f, 0640)
          else
            tar.add_file(f, 0640) { |tar_file| tar_file.write(File.open(f){|fl| fl.read})}
          end
        end
      end

      tar = output.tap(&:rewind).string
      connection.post(:path => '/build', :body => tar)
    end
  end
end
