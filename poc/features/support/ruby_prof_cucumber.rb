if ENV['RUBY_PROF'].present?
  require 'ruby-prof'
  RubyProf.start
 
  at_exit do
    results = RubyProf.stop
    File.open "#{Rails.root}/tmp/profile-graph.html", 'w' do |file|
      RubyProf::GraphHtmlPrinter.new(results).print(file)
    end 
 
    File.open "#{Rails.root}/tmp/profile-flat.txt", 'w' do |file|
      RubyProf::FlatPrinter.new(results).print(file)
    end 
  end 
end
