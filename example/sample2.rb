# simple usage of AmazeSNS - creating a topic and subscribing a user through email and unsubscribing

require 'rubygems'
require 'amaze_sns'

AmazeSNS.skey = 'xxxxxxxxxxxxxxxxxx'
AmazeSNS.akey = 'xxxxxxxxxxxxxxxxxx'

p AmazeSNS["new_list"].create

p AmazeSNS["new_list"].subscribe({:endpoint=>"test@test.com", :protocol => "email"})

p AmazeSNS["new_list"].attrs["SubscriptionsPending"] # should show 1 until user clicks on the email above

p AmazeSNS["new_list"].attrs["SubscriptionsConfirmed"] # should show 1 after user clicks on the email above

