# encoding: utf-8

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
  gem.name = "freya"
  gem.homepage = "http://github.com/rocketry/freya"
  gem.license = "MIT"
  gem.summary = %Q{Simple Solr Ruby interface}
  gem.description = %Q{Solr Ruby interface with connection proxying, efficient requests, and configurability.}
  gem.email = "duncan@impossiblerocket.com"
  gem.authors = ["Duncan Grazier", "Paul Guelpa"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = './spec/**/*_spec.rb'
  excluded = ENV['RCOV_EXCLUDES'] ? ENV['RCOV_EXCLUDES'].split(',') : []
  excluded += ['osx/','objc/','gems/','spec/','features/']
  spec.rcov_opts = %W{--rails --exclude #{excluded.join(',')}}
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "freya #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
