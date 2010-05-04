require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "amaze-sns"
    gemspec.summary = "Ruby gem for Amazon Simple Notification Service SNS"
    gemspec.description = "Ruby gem to interface with the Amazon Simple Notification Service"
    gemspec.email = "info@29steps.co.uk"
    gemspec.homepage = "http://github.com/cheeyeo/Amazon-SNS-Ruby"
    gemspec.authors = ["Chee Yeo", "29 Steps UK"]
    gemspec.add_dependency "eventmachine"
    gemspec.add_dependency "em-http"
    gemspec.add_dependency "crack"
    gemspec.add_dependency "http_client"
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
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