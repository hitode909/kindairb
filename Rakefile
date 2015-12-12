require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "kindai"
  gem.homepage = "http://github.com/hitode909/kindairb"
  gem.license = "MIT"
  gem.summary = %Q{kindai digital library downloader}
  gem.description = %Q{kindai.rb is kindai digital library downloader.}
  gem.email = "hitode909@gmail.com"
  gem.authors = ["hitode909"]

  gem.executables = ["kindai.rb"]
  gem.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "kindai #{version}"
  rdoc.rdoc_files.include('README.rdoc', 'LICENSE.txt', 'lib/**/*.rb')
  rdoc.main = 'README.rdoc'
end

