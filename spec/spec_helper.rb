require 'rubygems'

require 'rspec'
require 'rspec/autorun'
require 'em-http'
require 'webmock'
require 'webmock/rspec'
require 'vcr'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'amaze_sns'
require 'eventmachine'
#require 'support/vcr'

VCR.config do |c|
    c.cassette_library_dir     = 'fixtures/cassette_library'
    c.stub_with :webmock
    c.ignore_localhost         = true
    c.default_cassette_options = { :record => :none }
end

RSpec.configure do |config|
  config.include WebMock::API
  config.extend VCR::RSpec::Macros

end

