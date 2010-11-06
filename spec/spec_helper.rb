require 'rubygems'
require 'spec'
require 'spec/autorun'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# require 'lib/request'
require 'amaze_sns'
require 'eventmachine'


Spec::Runner.configure do |config|
 
end #end configure



