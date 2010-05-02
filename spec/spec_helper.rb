begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
  require 'spec/autorun'
end

# require 'webmock/rspec'
# 
# include WebMock

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'amaze_sns'
require 'eventmachine'