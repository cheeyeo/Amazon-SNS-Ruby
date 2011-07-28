$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "amaze_sns"
require "eventmachine"

AmazeSNS.skey = 'XXXXX'
AmazeSNS.akey = 'XXXXX'


EM.run{
  AmazeSNS.list_topics do |x|
    AmazeSNS.process_data(x)
    @topics = AmazeSNS.topics
  end
}

puts "TOPICS - #{@topics.inspect}"


EM.run{
  AmazeSNS.list_subscriptions do |x|
    AmazeSNS.process_data(x)
    @subs = AmazeSNS.subscriptions
  end
}

puts "SUBS - #{@subs.inspect}"