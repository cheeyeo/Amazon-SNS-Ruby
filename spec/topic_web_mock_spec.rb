require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'making requests to SNS API' do
  
  before :each do
    AmazeSNS.akey = '123456'
    AmazeSNS.skey = '123456'
    @time_stub = stub("Time")
    
    @data = <<-RESPONSE.gsub(/^ +/, '')
      <CreateTopicResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
        <CreateTopicResult>
          <TopicArn>arn:aws:sns:us-east-1:365155214602:MyTopic</TopicArn>
        </CreateTopicResult>
        <ResponseMetadata>
          <RequestId>0a7225aa-e9cb-11df-a5a1-293a0b8d0fcb</RequestId>
        </ResponseMetadata>
      </CreateTopicResponse>
    RESPONSE
    
    WebMock.reset!
    WebMock.disable_net_connect!
    
    @regexp = %r{/?Action=CreateTopic&Name=MyTopic}
  end
  
  it 'should send data to the API' do
    @time_stub.should_receive(:iso8601).and_return(123)
    Time.stub(:now).and_return(@time_stub)
   
    stub_http_request(:get, @regexp).to_return(:body => @data,
                                                :status => 200,
                                                :headers => {'Content-Type' => 'text/xml', 'Connection' => 'close'})
    
      @arn = AmazeSNS["MyTopic"].create
      @arn.should == "arn:aws:sns:us-east-1:365155214602:MyTopic"
      WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80})
    
  end
  
  it 'should return a deferrable' do
    t = Topic.new('MyTopic')
    
    @time_stub.should_receive(:iso8601).and_return(123)
    Time.stub(:now).and_return(@time_stub)
    
    stub_http_request(:get, @regexp).to_return(:body => @data, :status => 200)
    
    params = {
      'Name' => "MyTopic",
      'Action' => 'CreateTopic',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
     }
    
    EM.run{
      d = t.generate_request(params)
      d.callback{
        WebMock.should have_requested(:get, @regexp)
        EM.stop
      }
      d.errback{
        fail
        EM.stop
      }
    }
  end
  
  
  it 'should return a deferrable which fails if exception occurs' do
    t = Topic.new('MyTopic')
    
    @time_stub.should_receive(:iso8601).and_return(123)
    Time.stub(:now).and_return(@time_stub)
    AmazeSNS.akey = ''
    
    stub_http_request(:get, @regexp).to_return(:body => @data, :status => 403)
    
    params = {
      'Name' => "MyTopic",
      'Action' => 'CreateTopic',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
     }
    
    EM.run{
      d = t.generate_request(params)
      d.callback{
        fail
      }
      d.errback{|error|
        WebMock.should have_requested(:get, @regexp)
        error.should be_kind_of(AuthorizationError)
        EM.stop
      }
    }
    
    
  end
  
  
  
  
end