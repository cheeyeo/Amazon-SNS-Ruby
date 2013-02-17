require File.dirname(__FILE__) + '/spec_helper.rb'


describe AmazeSNS do
  
  before :each do
    WebMock.reset!
    WebMock.disable_net_connect!
  end
  
  
  describe 'in its initial state' do 
    it "should return the preconfigured host endpoint" do
      AmazeSNS.host.should == 'sns.us-east-1.amazonaws.com'
    end
    
    it "should return a blank Topics hash" do
      AmazeSNS.topics.should == {}
    end
    
    it "should return a blank Subscriptions hash" do
      AmazeSNS.subscriptions.should == {}
    end
    
    it 'should have the logger instantiated' do
      AmazeSNS.logger.debug('some message')
      AmazeSNS.logger.should be_kind_of(Logger)
    end
    
    it 'should be able to accept any kind of logger' do
      a_logger = mock("MyLogger")
      a_logger.should_receive(:debug).with('some data')
      AmazeSNS.logger = a_logger
      AmazeSNS.logger.debug('some data')
      AmazeSNS.logger = nil
    end
  end
  
  describe 'without the keys' do
    it 'should raise an ArgumentError if no keys are present' do
      AmazeSNS.skey=''
      AmazeSNS.akey=''
      lambda{
        AmazeSNS['test']
      }.should raise_error(AmazeSNS::CredentialError)
    end
  end
  
  describe 'with the keys configured' do   
    before do
      AmazeSNS.akey = '123456'
      AmazeSNS.skey = '123456'
      @topic = AmazeSNS['Test']
    end

    it 'should return a new topic object' do
      @topic.should be_kind_of(Topic)
      @topic.topic.should == 'Test'
    end
  end
  
  describe 'making the api calls' do
    before :each do
      AmazeSNS.akey = '123456'
      AmazeSNS.skey = '123456'
    end
    
    it 'should be able to list topics' do
      @data = <<-RESPONSE.gsub(/^ +/, '')
        <ListTopicsResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
          <ListTopicsResult>
            <Topics>
              <member>
                <TopicArn>arn:aws:sns:us-east-1:123456789012:My-Topic</TopicArn>
              </member>
             </Topics> 
          </ListTopicsResult> 
          <ResponseMetadata>
            <RequestId>3f1478c7-33a9-11df-9540-99d0768312d3</RequestId>
          </ResponseMetadata>
        </ListTopicsResponse>
      RESPONSE

      @regexp = %r{/?Action=ListTopics}
      
      stub_http_request(:get, @regexp).to_return(:body => @data,
                                                 :status => 200,
                                                 :headers => {
                                                   'Content-Type' => 'text/xml', 
                                                   'Connection' => 'close'
                                                  })
      
       AmazeSNS.should respond_to(:method_missing)
       AmazeSNS.should respond_to(:process_query).with(1).argument
       
       EM.run_block{
         AmazeSNS.list_topics do |x|
           AmazeSNS.process_data(x)
         end
       }
       
       AmazeSNS.topics.has_key?('My-Topic').should == true
       AmazeSNS['My-Topic'].should be_instance_of Topic
       AmazeSNS['My-Topic'].topic.should == 'My-Topic'
       AmazeSNS['My-Topic'].arn.should == 'arn:aws:sns:us-east-1:123456789012:My-Topic'
       WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80})
    end
    
    it 'should be able to list subscriptions' do
      @data = <<-RESPONSE.gsub(/^ +/, '')
        <ListSubscriptionsResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/"> 
          <ListSubscriptionsResult>
            <Subscriptions> 
              <member>
                <TopicArn>arn:aws:sns:us-east-1:698519295917:My-Topic</TopicArn> 
                <Protocol>email</Protocol>
                <SubscriptionArn>arn:aws:sns:us-east-1:123456789012:My-Topic:80289ba6- 0fd4-4079-afb4-ce8c8260f0ca</SubscriptionArn>
                <Owner>123456789012</Owner>
                <Endpoint>example@amazon.com</Endpoint>
              </member>
             </Subscriptions> 
           </ListSubscriptionsResult> 
          <ResponseMetadata>
            <RequestId>384ac68d-3775-11df-8963-01868b7c937a</RequestId> 
          </ResponseMetadata>
        </ListSubscriptionsResponse>
      RESPONSE

      @regexp = %r{/?Action=ListSubscriptions}
      
      stub_http_request(:get, @regexp).to_return(:body => @data,
                                                 :status => 200,
                                                 :headers => {
                                                   'Content-Type' => 'text/xml', 
                                                   'Connection' => 'close'
                                                  })
      
      AmazeSNS.should respond_to(:method_missing)
      AmazeSNS.should respond_to(:process_query).with(1).argument
      
       EM.run_block{
         AmazeSNS.list_subscriptions do |x|
           AmazeSNS.process_data(x)
           @subs = AmazeSNS.subscriptions
         end
       }
       
       @subs['My-Topic'].should be_instance_of SNSSubscription
       @subs['My-Topic'].owner.should == '123456789012'
       @subs['My-Topic'].protocol.should == 'email'
       @subs['My-Topic'].topicarn.should == 'arn:aws:sns:us-east-1:698519295917:My-Topic'
       @subs['My-Topic'].endpoint.should == 'example@amazon.com'
       @subs['My-Topic'].subarn.should == 'arn:aws:sns:us-east-1:123456789012:My-Topic:80289ba6- 0fd4-4079-afb4-ce8c8260f0ca'
       WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80})
    end
    
    it 'should respond with an error' do
      @regexp = %r{/?Action=ListSubscriptions}
      stub_http_request(:get, @regexp).to_return(:status => [500, "Internal Server Error"])
      error_raised = nil
      begin
        EM.run{
          AmazeSNS.list_subscriptions {|x| }
        }
      rescue => e
        error_raised = e
      end
      
      e.class.should == InternalError
      e.message.should == 'An internal service error has occured on the Simple Notification Service'
    end
    
  end# end api tests
  
  
  after do
    AmazeSNS.topics={}
    AmazeSNS.subscriptions={}
  end
  
 
end # end outer describe


