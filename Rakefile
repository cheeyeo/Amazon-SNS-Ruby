require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "amaze_sns"
    gemspec.summary = "Ruby gem for Amazon Simple Notification Service SNS"
    gemspec.description = "Ruby gem to interface with the Amazon Simple Notification Service"
    gemspec.email = "info@29steps.co.uk"
    gemspec.homepage = "http://29steps.co.uk"
    gemspec.authors = ["Chee Yeo", "29 Steps UK"]
    gemspec.required_ruby_version = ">= 1.8.6"
    gemspec.add_dependency('eventmachine', '>= 0.12.10')
    gemspec.add_dependency("em-http-request", '>= 0.2.8')
    gemspec.add_dependency("crack", '>=0.1.6')
    gemspec.add_dependency "ruby-hmac", ">=0.4.0"
    gemspec.add_dependency "json", ">=1.4.3"
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_development_dependency "webmock", "~> 1.6.0.pre"
    gemspec.files = FileList['lib/*.rb', 'lib/**/*.rb']
    gemspec.test_files = ['spec/*.rb', 'spec/spec.opts']
  end
  Jeweler::GemcutterTasks.new
  
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end



task :spec => :check_dependencies

task :default => :spec