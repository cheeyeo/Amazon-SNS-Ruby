require 'rubygems'
require 'vcr'

#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..','fixtures'))

VCR.config do |c|
    c.cassette_library_dir     = 'fixtures/cassette_library'
    c.stub_with :webmock
    c.ignore_localhost         = true
    c.default_cassette_options = { :record => :none }
end