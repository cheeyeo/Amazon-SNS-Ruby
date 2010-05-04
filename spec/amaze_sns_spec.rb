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
      AmazeSNS.akey = '12346'
      AmazeSNS.skey =  '123456'
      
      @response_stub = stub()
      @response_stub.stub!(:errback)
      #@response_stub.stub!(:callback)
       @on_error = Proc.new {|http| p "CALLED"}
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
    
    it 'should make a call to em-http-request' do
      request = mock(:get => @response_stub)
      EventMachine::MockHttpRequest.should_receive(:new).with("http://#{AmazeSNS.host}/?#{@querystring2}").and_return(request)
      AmazeSNS.send(:list_topics)
    end
    
    it 'should return xml of topics' do
      EventMachine::MockHttpRequest.register("http://#{AmazeSNS.host}/?#{@querystring2}", "GET", "test", fake_response)
      
      # commented out for now as above does not seem to register the url which means it will make an actual call to the service.
      # EM.run {
      #         AmazeSNS.list_topics do |response|
      #           response.response.should == fake_response # cannot get the string to match up due to whitespace??
      #           EM.stop
      #         end
      #       }
    end
    
  end
  
  after do
    
  end
  
 
end # end outer describe


