require File.dirname(__FILE__) + '/spec_helper.rb'
require "em-http"


describe Topic do
  before do
    
    AmazeSNS.akey = '123456'
    AmazeSNS.skey = '123456'
    
    @attrs_hash = { "SubscriptionsConfirmed"=>"2", 
                    "SubscriptionsPending"=>"0", 
                    "Owner"=>"365155214602", 
                    "TopicArn"=>"arn:aws:sns:us-east-1:365155214602:cars55", 
                    "SubscriptionsDeleted"=>"0", 
                    "Policy"=>{"Version"=>"2008-10-17", 
                               "Id"=>"us-east-1/365155214602/cars55__default_policy_ID", 
                               "Statement"=>[{"Action"=>["SNS:GetTopicAttributes", "SNS:SetTopicAttributes", "SNS:AddPermission", "SNS:RemovePermission", "SNS:DeleteTopic", "SNS:Subscribe", "SNS:ListSubscriptionsByTopic", "SNS:Publish", "SNS:Receive"], 
                                              "Sid"=>"us-east-1/365155214602/cars55__default_statement_ID", 
                                              "Resource"=>"arn:aws:sns:us-east-1:365155214602:cars55", 
                                              "Principal"=>{"AWS"=>"*"}, 
                                              "Condition"=>{"StringLike"=>{"AWS:SourceArn"=>"arn:aws:*:*:365155214602:*"}}, "Effect"=>"Allow"}]
                                }# end policy hash
                    } # end outer hash

    @topic = Topic.new('my_test_topic', 'arn:123456')
    @topic.attributes = @attrs_hash
    @topic.stub!(:attrs).and_return(@attrs_hash)
  end
  
  describe 'in its initial state' do
    it 'should be an instance of Topic class' do
      @topic.should be_kind_of(Topic)
    end
    
    it 'should return the topic name and arn when requested' do
      @topic.topic.should == 'my_test_topic'
      @topic.arn.should == 'arn:123456'
    end
    
    it 'should return the attributes when requested' do
      @topic.attrs.should be_kind_of(Hash)
      @topic.attrs["SubscriptionsConfirmed"].should == "2"
      @topic.attrs["Owner"].should == "365155214602"
      
      @topic.attributes.should == @topic.attrs
    end
    
  end
  
  describe 'when creating a topic' do
    before :each do
      AmazeSNS.akey = '123456'
      AmazeSNS.skey = '123456'
      
      @url = 'http://sns.us-east-1.amazonaws.com:80/?Action=CreateTopic&Signature=t8VXbA2gjfYwaBO9C9MtySwGjUphjhtgNBUZBxbuOrU%3D&Name=MyTopic&AWSAccessKeyId=123456&Timestamp=123&SignatureVersion=2&SignatureMethod=HmacSHA256'
      EventMachine::MockHttpRequest.reset_registry!
      EventMachine::MockHttpRequest.reset_counts!
      EventMachine::MockHttpRequest.pass_through_requests = false #set to false to not hit the actual API endpoint
      
      @time_stub = stub("Time")
    end
    
    it 'should make a call to the API' do
      @time_stub.should_receive(:iso8601).and_return(123)
      Time.stub(:now).and_return(@time_stub)
      
      EventMachine::MockHttpRequest.use{
        data = <<-RESPONSE.gsub(/^ +/, '')
          HTTP/1.0 200 OK
          Date: Mon, 16 Nov 2009 20:39:15 GMT
          Content-Type: text/xml; charset=ISO-8859-1
          Connection: close

          <CreateTopicResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
            <CreateTopicResult>
              <TopicArn>arn:aws:sns:us-east-1:365155214602:MyTopic</TopicArn>
            </CreateTopicResult>
            <ResponseMetadata>
              <RequestId>0a7225aa-e9cb-11df-a5a1-293a0b8d0fcb</RequestId>
            </ResponseMetadata>
          </CreateTopicResponse>
        RESPONSE
        
        EventMachine::MockHttpRequest.register(@url,:get,{},data)
        
        EM.run{
          @arn = AmazeSNS["MyTopic"].create
          @arn.should == "arn:aws:sns:us-east-1:365155214602:MyTopic"
          EM::HttpRequest.count(@url, :get).should == 1
          EM.stop
        }
        
      }
    end
    
    it 'should add the new topic to the topics hash' do
      AmazeSNS.topics.key?("MyTopic").should == true
    end
    
  end
  
  describe 'when deleting a topic' do
    before :each do
      @url = 'http://sns.us-east-1.amazonaws.com:80/?Action=DeleteTopic&Signature=LWEpw341qLW9xnLp%2FlL9D1s7lSqgHVPFh9qvaOe%2FtJw%3D&AWSAccessKeyId=123456&TopicArn=arn%3Aaws%3Asns%3Aus-east-1%3A365155214602%3AMyTopic&Timestamp=123&SignatureVersion=2&SignatureMethod=HmacSHA256'
      EventMachine::MockHttpRequest.reset_registry!
      EventMachine::MockHttpRequest.reset_counts!
      EventMachine::MockHttpRequest.pass_through_requests = false #set to false to not hit the actual API endpoint
      
      @time_stub = stub("Time")
    end
    
    it 'should make a call to the API' do
      @time_stub.should_receive(:iso8601).and_return(123)
      Time.stub(:now).and_return(@time_stub)
      
      EventMachine::MockHttpRequest.use{
        data = <<-RESPONSE.gsub(/^ +/, '')
          HTTP/1.0 200 OK
          Date: Mon, 16 Nov 2009 20:39:15 GMT
          Content-Type: text/xml; charset=ISO-8859-1
          Connection: close

          <DeleteTopicResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
            <ResponseMetadata>
              <RequestId>8df7aa0b-e9cd-11df-b6a2-a1771dd8fa64</RequestId>
            </ResponseMetadata>
          </DeleteTopicResponse>
        RESPONSE
        
        EventMachine::MockHttpRequest.register(@url,:get,{},data)
        
        EM.run{
          @output = AmazeSNS["MyTopic"].delete
          @output["DeleteTopicResponse"]["ResponseMetadata"]["RequestId"].should == "8df7aa0b-e9cd-11df-b6a2-a1771dd8fa64"
          EM::HttpRequest.count(@url, :get).should == 1
          EM.stop
        }
      }
    end
    
    it 'should remove the topic object from the topics hash' do
      AmazeSNS.topics.key?("MyTopic").should == false
    end
    
  end
  
  describe 'when accessing its attributes' do
  end
  
  describe 'when setting its attributes' do
  end
end