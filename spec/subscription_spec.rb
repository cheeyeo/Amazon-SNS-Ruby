require File.dirname(__FILE__) + '/spec_helper.rb'

describe Subscription do
  before :each do
    hsh = {
      "Owner" => '123456789012',
      "Protocol" => 'email',
      "TopicArn" => 'arn:aws:sns:us-east-1:698519295917:My-Topic',
      "Endpoint" => 'example@amazon.com',
      "SubscriptionArn" => 'arn:aws:sns:us-east-1:123456789012:My-Topic:80289ba6- 0fd4-4079-afb4-ce8c8260f0ca'
    }
    @subscription = Subscription.new(hsh)  
  end
  
  it 'should be an instance of subscription' do
    @subscription.should be_instance_of Subscription
  end
  
  it 'should have attributes that are accessible' do
    @subscription.owner.should == '123456789012'
    @subscription.protocol.should == 'email'
    @subscription.topicarn.should == 'arn:aws:sns:us-east-1:698519295917:My-Topic'
    @subscription.endpoint.should == 'example@amazon.com'
    @subscription.subarn.should == 'arn:aws:sns:us-east-1:123456789012:My-Topic:80289ba6- 0fd4-4079-afb4-ce8c8260f0ca'
  end
      
end