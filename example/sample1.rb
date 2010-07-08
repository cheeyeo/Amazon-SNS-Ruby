# simple usage of AmazeSNS - listing topics , creating a new topic, getting its attrs

require 'rubygems'
require 'amaze_sns'

AmazeSNS.skey = 'xxxxxxxxxxxxxxxxxx'
AmazeSNS.akey = 'xxxxxxxxxxxxxxxxxx'

AmazeSNS.list_topics
p "Topics: #{AmazeSNS.topics.inspect}"

p AmazeSNS["new_list"].create

p AmazeSNS["new_list"].attrs