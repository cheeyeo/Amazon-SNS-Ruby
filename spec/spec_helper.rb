require 'rubygems'

require 'rspec'
require 'rspec/autorun'
require 'em-http'
require 'webmock'
require 'webmock/rspec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'amaze_sns'
require 'eventmachine'


RSpec.configure do |config|
  config.include WebMock::API
end

