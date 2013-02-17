class SNSSubscription
  
  attr_accessor :owner, :protocol, :topicarn, :endpoint, :subarn
  
  def initialize(args)
    @owner = args["Owner"]
    @protocol = args["Protocol"]
    @topicarn = args["TopicArn"]
    @endpoint = args["Endpoint"]
    @subarn = args["SubscriptionArn"]
  end
  
  def to_s
    "Subscription: Owner - #{@owner} : Protocol - #{@protocol} : TopicARN - #{@topicarn} : EndPoint - #{@endpoint} : SubscriptionARN - #{@subarn}"
  end
  
end
