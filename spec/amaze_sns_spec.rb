#require File.dirname(__FILE__) + '/spec_helper.rb'
require File.expand_path('../spec_helper', __FILE__)

require 'em-http'

describe AmazeSNS do
  
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
    end
  end
  
  describe 'without the keys' do
    it 'should raise an ArgumentError if no keys are present' do
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
      @url = 'http://sns.us-east-1.amazonaws.com:80/?Action=ListTopics&Signature=ItTAjeexIPC43pHMZLCL7utnpK8j8AbTUZ3KGUSMzNc%3D&AWSAccessKeyId=123456&Timestamp=123&SignatureVersion=2&SignatureMethod=HmacSHA256'
      EventMachine::MockHttpRequest.reset_registry!
      EventMachine::MockHttpRequest.reset_counts!
      EventMachine::MockHttpRequest.pass_through_requests = false #set to false to not hit the actual API endpoint
      
      @time_stub = stub("A")
    end
    
    it 'should be able to access the API endpoint' do
      @time_stub.should_receive(:iso8601).and_return(123)
      Time.stub(:now).and_return(@time_stub)
      
      EventMachine::MockHttpRequest.use {
        data = <<-RESPONSE.gsub(/^ +/, '')
          HTTP/1.0 200 OK
          Date: Mon, 16 Nov 2009 20:39:15 GMT
          Expires: -1
          Cache-Control: private, max-age=0
          Content-Type: text/html; charset=ISO-8859-1
          Via: 1.0 .:80 (squid)
          Connection: close

          This is my awesome content
        RESPONSE
        
        EventMachine::MockHttpRequest.register(@url,:get,{},data)
        
        EM.run{
          d = AmazeSNS.list_topics
          d.callback{
            EM::HttpRequest.count(@url, :get).should == 1
            EM.stop
          }
          d.errback{|error|
            EM.stop
          }
        }

      } #end EM:MockHttpRequest block
    end
    
    it 'should return a deferrable on fail' do
      @time_stub.should_receive(:iso8601).and_return(123)
      Time.stub(:now).and_return(@time_stub)
      
      EventMachine::MockHttpRequest.use {
        data = <<-RESPONSE.gsub(/^ +/, '')
          HTTP/1.0 403 Unauthorized
          Date: Mon, 16 Nov 2009 20:39:15 GMT
          Expires: -1
          Cache-Control: private, max-age=0
          Content-Type: text/html; charset=ISO-8859-1
          Via: 1.0 .:80 (squid)
          Connection: close

          403 UNAUTHORIZED: Some error
        RESPONSE

        EventMachine::MockHttpRequest.register(@url,:get,{},data)
        
        EM.run{
           d= AmazeSNS.list_topics
           d.callback{
             fail
           }
           d.errback{|error|
             EM::HttpRequest.count(@url, :get).should == 1
             error.should be_kind_of(AuthorizationError)
             EM.stop
           }
          
        } 
        
      } #end EM:MockHttpRequest block
    end
    
    it 'should call method_missing and process_query' do
      @time_stub.should_receive(:iso8601).and_return(123)
      Time.stub(:now).and_return(@time_stub)
      
      #rspec expectations matchers
      AmazeSNS.should respond_to(:method_missing)
      AmazeSNS.should respond_to(:process_query).with(1).argument
      
      data = <<-RESPONSE.gsub(/^ +/, '')
        HTTP/1.0 200 OK
        Date: Mon, 16 Nov 2009 20:39:15 GMT
        Expires: -1
        Cache-Control: private, max-age=0
        Content-Type: text/html; charset=ISO-8859-1
        Via: 1.0 .:80 (squid)
        Connection: close

        This is my awesome content
      RESPONSE
      
      EventMachine::MockHttpRequest.use{
        EventMachine::MockHttpRequest.register(@url,:get,{},data)
          
          EM.run{
            AmazeSNS.list_topics
            EM.stop
          }

      } #end EM:MockHttpRequest block
    end
    
    
  end
  
  after do
    AmazeSNS.topics={}
    AmazeSNS.subscriptions={}
  end
  
 
end # end outer describe


