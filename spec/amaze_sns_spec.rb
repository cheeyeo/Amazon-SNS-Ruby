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
 

  describe 'Request#process' do
    module EventMachine
      module HttpEncoding
                def encode_query(path, query, uri_query)
          encoded_query = if query.kind_of?(Hash)
            query.sort{|a, b| a.to_s <=> b.to_s}.
            map { |k, v| encode_param(k, v) }.
            join('&')
          else
            query.to_s
          end
          if !uri_query.to_s.empty?
            encoded_query = [encoded_query, uri_query].reject {|part| part.empty?}.join("&")
          end
          return path if encoded_query.to_s.empty?
          "#{path}?#{encoded_query}"
        end
      end
    end
    
    before :each do
      EM::HttpRequest = EM::MockHttpRequest
      EM::HttpRequest.reset_registry!
      EM::HttpRequest.reset_counts!
      EM::HttpRequest.pass_through_requests = false
      
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
    
    it "should return a deferrable which succeeds in success case" do
      #Time.stub(:now).and_return(123)
    
      data = <<-RESPONSE.gsub(/^ +/, '')
                   HTTP/1.1 202 Accepted
                   Content-Type: text/html
                   Content-Length: 13
                   Connection: keep-alive
                   Server: thin 1.2.7 codename No Hup
           
                   202 ACCEPTED
      RESPONSE
      
      url = "http://#{AmazeSNS.host}/?#{@querystring2}"
      
      EM::HttpRequest.register(url, :get, data)
      
      EM.run {
        d = AmazeSNS.list_topics
        d.callback{
            @raw_resp = Crack::XML.parse(resp.response)
            AmazeSNS.process_response(@raw_resp)
            EM.stop
        }
      }
      
      
    end
    
    
  end
  
  
  
  
  after do
    AmazeSNS.topics={}
  end
  
 
end # end outer describe


