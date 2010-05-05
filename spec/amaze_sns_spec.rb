require File.dirname(__FILE__) + '/spec_helper.rb'

describe AmazeSNS do
  
  before(:each) do
    EventMachine::MockHttpRequest.reset_counts!
    EventMachine::MockHttpRequest.reset_registry!
  end
  
  describe 'in its initial state' do
  
    it "should return the preconfigured host endpoint" do
      AmazeSNS.host.should == 'sns.us-east-1.amazonaws.com'
    end
    
    it "should return a blank Topics hash" do
      AmazeSNS.topics.should == {}
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
 
  describe 'calling list_topics' do
    before do
     
     #EM::MockHTTPRequest registered method not workig so making actual calls to service!
     # subsititue the values below for your actual keys if you want to run this test
     # else you will receive a permission error
      AmazeSNS.akey = 'xxxxxxxx'
      AmazeSNS.skey =  'xxxxxxx'
      @response_stub = stub()
      @response_stub.stub!(:errback)
      @response_stub.stub!(:callback)
   
       @params = {
        'Action' => 'ListTopics',
        'SignatureMethod' => 'HmacSHA256',
        'SignatureVersion' => 2,
        'Timestamp' => Time.now.iso8601,
        'AWSAccessKeyId' => AmazeSNS.akey
      }

      @query_string = canonical_querystring(@params)

string_to_sign = "GET
#{AmazeSNS.host}
/
#{@query_string}"

      hmac = HMAC::SHA256.new(AmazeSNS.skey)
      hmac.update( string_to_sign )
      signature = Base64.encode64(hmac.digest).chomp

      @params['Signature'] = signature
      @querystring2 = @params.collect { |key, value| [url_encode(key), url_encode(value)].join("=") }.join('&')
    end
    
    it 'should make a call to method_missing' do
      AmazeSNS.should_receive(:method_missing).once
      AmazeSNS.list_topics
    end
    
    it 'should raise NoMethodError if the method is not valid' do
       lambda{
          AmazeSNS.error_method
        }.should raise_error(NoMethodError)
    end
    
    it 'should invoke em-http-request' do
      request = mock('em-http', :get => @response_stub)
      EventMachine::MockHttpRequest.should_receive(:new).with("http://#{AmazeSNS.host}/?#{@querystring2}").and_return(request)
      AmazeSNS.list_topics
    end
    
    it 'should return the raw xml response as a string and process it into a hash' do
      EventMachine::MockHttpRequest.register("http://#{AmazeSNS.host}/?#{@querystring2}", "GET", {}, fake_response)
      # may have to disable em.run loop within amaze_sns line 74 to get beyond the block below??
      EM.run{
        AmazeSNS.list_topics do |resp|
          @raw_resp = Crack::XML.parse(resp.response)
          AmazeSNS.process_response(@raw_resp)
          EM.stop
        end  
      }
      
      AmazeSNS.topics.keys.size.should > 1
    end
  
    
  end
  
  after do
    AmazeSNS.topics={}
  end
  
 
end # end outer describe


