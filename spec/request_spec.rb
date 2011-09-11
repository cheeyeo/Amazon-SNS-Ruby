require File.dirname(__FILE__) + '/spec_helper.rb'

describe Request do
  before :each do
    AmazeSNS.akey = '123456'
    AmazeSNS.skey = '123456'
    
    params={
      'Action' => "ListTopics",
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601, #Time.now.iso8601 makes tests fail
      'AWSAccessKeyId' => AmazeSNS.akey
    }
    
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
    
    @request = Request.new(params)
  end
  
  it 'should make a request successfully' do
    @regexp = %r{/?Action=ListTopics}
    stub_http_request(:get, @regexp).to_return(:body => @data,
                                               :status => 200,
                                               :headers => {
                                                 'Content-Type' => 'text/xml', 
                                                 'Connection' => 'close'
                                                })
                                                
    EM.run_block{ 
      @request.process
      @request.callback{|data|
        data.response.should == @data
      }
    }
    WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80})
  end
  
  it 'should throw an error if the request is not successful' do
    error_raised = nil
    @regexp = %r{/?Action=ListTopics}
    stub_http_request(:get, @regexp).to_return(:status => [500, "Internal Server Error"])
    
    begin
      EM.run_block{
        @request.process
      }
    rescue => e
      error_raised = e
    end
    
    e.class.should == InternalError
    e.message.should == 'An internal service error has occured on the Simple Notification Service'
  end
  
end