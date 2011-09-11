require File.dirname(__FILE__) + '/spec_helper.rb'

describe Topic do
  describe 'in its initial state' do
    before :each do
      @attrs_hash = { "SubscriptionsConfirmed"=>"2", 
                        "SubscriptionsPending"=>"0", 
                        "Owner"=>"365155214602", 
                        "TopicArn"=>"arn:aws:sns:us-east-1:365155214602:my_test_topic", 
                        "SubscriptionsDeleted"=>"0", 
                        "Policy"=>{"Version"=>"2008-10-17", 
                                   "Id"=>"us-east-1/365155214602/cars55__default_policy_ID", 
                                   "Statement"=>[{"Action"=>["SNS:GetTopicAttributes", "SNS:SetTopicAttributes", "SNS:AddPermission", "SNS:RemovePermission", "SNS:DeleteTopic", "SNS:Subscribe", "SNS:ListSubscriptionsByTopic", "SNS:Publish", "SNS:Receive"], 
                                                  "Sid"=>"us-east-1/365155214602/my_test_topic__default_statement_ID", 
                                                  "Resource"=>"arn:aws:sns:us-east-1:365155214602:my_test_topic", 
                                                  "Principal"=>{"AWS"=>"*"}, 
                                                  "Condition"=>{"StringLike"=>{"AWS:SourceArn"=>"arn:aws:*:*:365155214602:*"}}, "Effect"=>"Allow"}]
                                    }# end policy hash
                        } # end outer hash
    
      @topic = Topic.new('my_test_topic', 'arn:123456')
      @topic.attributes = @attrs_hash
      @topic.stub!(:attrs).and_return(@attrs_hash)
    end
    
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
  
  end

  describe 'operations through the API' do
    before :each do
      AmazeSNS.akey = '123456'
      AmazeSNS.skey = '123456'
      @time_stub = stub("Time")
      @subscriptions = {}
      WebMock.reset!
      WebMock.disable_net_connect!
    end
    
    
    context 'creating a topic' do
      before :each do
        
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
        WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
      end
      
      it 'should add the new topic to the topics hash' do
        AmazeSNS.topics.has_key?("MyTopic").should == true
      end
      
    end # end create topic spec
    
    context 'getting a topic attrs' do
      before :each do
        @attrs_data = <<-RESPONSE.gsub(/^ +/, '')
          <GetTopicAttributesResponse xmlns=\"http://sns.amazonaws.com/doc/2010-03-31/\">
            <GetTopicAttributesResult>
              <Attributes>
                <entry>
                  <key>Owner</key> 
                  <value>365155214602</value>
                </entry>
                <entry>
                  <key>SubscriptionsPending</key>
                  <value>0</value>
                </entry>
                <entry>
                  <key>Policy</key>
                  <value>{   &quot;Version&quot;:&quot;2008-10-17&quot;,&quot;Id&quot;:&quot;us-east-1/365155214602/MyTopic__default_policy_ID&quot;,&quot;Statement&quot;:[{&quot;Sid&quot;:&quot;us-east-1/365155214602/MyTopic__default_statement_ID&quot;,&quot;Effect&quot;:&quot;Allow&quot;,&quot;Principal&quot;:{&quot;AWS&quot;:&quot;*&quot;},&quot;Action&quot;:[&quot;SNS:Publish&quot;,&quot;SNS:RemovePermission&quot;,&quot;SNS:SetTopicAttributes&quot;,&quot;SNS:DeleteTopic&quot;,&quot;SNS:ListSubscriptionsByTopic&quot;,&quot;SNS:GetTopicAttributes&quot;,&quot;SNS:Receive&quot;,&quot;SNS:AddPermission&quot;,&quot;SNS:Subscribe&quot;],&quot;Resource&quot;:&quot;arn:aws:sns:us-east-1:365155214602:MyTopic&quot;,&quot;Condition&quot;:{&quot;StringLike&quot;:{&quot;AWS:SourceArn&quot;:&quot;arn:aws:*:*:365155214602:*&quot;}}}]}</value>
                  </entry>
                  <entry>
                    <key>SubscriptionsConfirmed</key>
                    <value>2</value>
                  </entry>
                  <entry>
                    <key>SubscriptionsDeleted</key>
                    <value>0</value>
                  </entry>
                  <entry>
                    <key>TopicArn</key>
                    <value>arn:aws:sns:us-east-1:365155214602:MyTopic</value>
                  </entry>
                </Attributes>
              </GetTopicAttributesResult>
              <ResponseMetadata>
                <RequestId>54c67339-0acd-11e0-8483-c91fbf41249a</RequestId>
              </ResponseMetadata>
          </GetTopicAttributesResponse>
        RESPONSE
        
        @regexp = %r{/?Action=GetTopicAttributes}
      end
      
      
      it 'should make the API call' do
        @time_stub.should_receive(:iso8601).and_return(123)
        Time.stub(:now).and_return(@time_stub)

        stub_http_request(:get, @regexp).to_return(:body => @attrs_data,
                                                    :status => 200,
                                                    :headers => {})
        
         AmazeSNS["MyTopic"].attrs
         WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
         WebMock.should have_requested(:get, @regexp).once
      end
      
      it 'should store its attributes into a hash' do
        @outcome = AmazeSNS["MyTopic"].attributes
        @outcome.should be_kind_of(Hash)
        @outcome.has_key?("Owner").should be_true
        @outcome.has_key?("TopicArn").should be_true
        
        @outcome["Owner"].should == "365155214602"
        @outcome["TopicArn"].should == "arn:aws:sns:us-east-1:365155214602:MyTopic"
        @outcome["Policy"]["Version"].should == "2008-10-17"
        @outcome["Policy"]["Id"].should == "us-east-1/365155214602/MyTopic__default_policy_ID"
        @outcome["Policy"]["Statement"][0]["Action"].should == ["SNS:Publish","SNS:RemovePermission","SNS:SetTopicAttributes","SNS:DeleteTopic","SNS:ListSubscriptionsByTopic","SNS:GetTopicAttributes","SNS:Receive","SNS:AddPermission","SNS:Subscribe"]
        @outcome["Policy"]["Statement"][0]["Resource"].should == "arn:aws:sns:us-east-1:365155214602:MyTopic"
      end
      
      
    end # end of topic attrs
    
    context 'subscribing to a topic' do
      before :each do
         @sub_data = <<-RESPONSE.gsub(/^ +/, '')
           <SubscribeResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/"> 
             <SubscribeResult>
               <SubscriptionArn>pending confirmation</SubscriptionArn> 
              </SubscribeResult> 
              <ResponseMetadata>
                <RequestId>a169c740-3766-11df-8963-01868b7c937a</RequestId>
              </ResponseMetadata>
           </SubscribeResponse>
          RESPONSE

          @regexp = %r{/?Action=Subscribe}
      end
      
      
      it 'should recive a pending confirmation on subscription' do
        @time_stub.should_receive(:iso8601).and_return(123)
        Time.stub(:now).and_return(@time_stub)
        
        stub_http_request(:get, @regexp).to_return(:body => @sub_data,
                                                    :status => 200,
                                                    :headers => {'Content-Type' => 'text/xml', 'Connection' => 'close'})
        
        res = AmazeSNS["MyTopic"].subscribe(:endpoint => "example@amazon.com", :protocol => "email")
        WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
        WebMock.should have_requested(:get, @regexp).once
        res.should == "pending confirmation"
      end
    end
    
    context 'setting a topic attrs' do
      before :each do
        @data = <<-RESPONSE.gsub(/^ +/, '')
          <SetTopicAttributesResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/"> 
            <ResponseMetadata>
              <RequestId>a8763b99-33a7-11df-a9b7-05d48da6f042</RequestId> 
            </ResponseMetadata>
          </SetTopicAttributesResponse>
        RESPONSE
        
        @regexp = %r{/?Action=SetTopicAttributes}
      end
      
      
      it 'should set the topics attrs' do
         @time_stub.should_receive(:iso8601).and_return(123)
          Time.stub(:now).and_return(@time_stub)

          stub_http_request(:get, @regexp).to_return(:body => @data,
                                                      :status => 200,
                                                      :headers => {'Content-Type' => 'text/xml', 'Connection' => 'close','Status' => 200})
          
          AmazeSNS["MyTopic"].set_attrs({:name => "TopicArn", :value => 'lorem ipsum'})

          WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
          WebMock.should have_requested(:get, @regexp).once
      end
      
      it 'should update the attributes hash' do
        AmazeSNS["MyTopic"].attributes["TopicArn"].should == 'lorem ipsum'
      end
    end
    
    context 'subscriptions to a topic' do
      before :each do
        @sub_data = <<-RESPONSE.gsub(/^ +/, '')
          <ListSubscriptionsByTopicResponse xmlns="http://sns.amazonaws.com/ doc/2010-03-31/">
            <ListSubscriptionsByTopicResult>
              <Subscriptions>
                <member> 
                  <TopicArn>arn:aws:sns:us-east-1:123456789012:MyTopic</TopicArn> 
                  <Protocol>email</Protocol> 
                  <SubscriptionArn>arn:aws:sns:us-east-1:123456789012:MyTopic:80289ba6-0fd4-4079-afb4-ce8c8260f0ca</SubscriptionArn> 
                  <Owner>123456789012</Owner>
                  <Endpoint>example@amazon.com</Endpoint> 
                </member>
              </Subscriptions> 
              </ListSubscriptionsByTopicResult> 
              <ResponseMetadata>
                <RequestId>b9275252-3774-11df-9540-99d0768312d3</RequestId> 
              </ResponseMetadata>
            </ListSubscriptionsByTopicResponse>
        RESPONSE
        
        @regexp = %r{/?Action=ListSubscriptionsByTopic}
      end
      
      
      it 'should list the subscriptions for this topic' do
        @time_stub.should_receive(:iso8601).and_return(123)
        Time.stub(:now).and_return(@time_stub)
        
        stub_http_request(:get, @regexp).to_return(:body => @sub_data,
                                                    :status => 200,
                                                    :headers => {'Content-Type' => 'text/xml', 'Connection' => 'close'})
        
        entry_hash = {
                        "Owner" => "123456789012",
                        "Endpoint" => "example@amazon.com",
                        "Protocol" => "email",
                        "TopicArn" => "arn:aws:sns:us-east-1:123456789012:MyTopic"
                      }
        subkey = "arn:aws:sns:us-east-1:123456789012:MyTopic:80289ba6-0fd4-4079-afb4-ce8c8260f0ca"
        @subscriptions = AmazeSNS["MyTopic"].subscriptions
        @subscriptions[subkey].should == entry_hash
        @subscriptions[subkey]["Owner"].should == "123456789012"
        @subscriptions[subkey]["Endpoint"].should == "example@amazon.com"
        @subscriptions[subkey]["Protocol"].should == "email"
        @subscriptions[subkey]["TopicArn"].should == "arn:aws:sns:us-east-1:123456789012:MyTopic"
        
        WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
        WebMock.should have_requested(:get, @regexp).once
      end
    end
    
    context 'unsubscribing from a topic' do
      
      before :each do
        @data = <<-RESPONSE.gsub(/^ +/, '')
          <UnsubscribeResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/"> 
            <ResponseMetadata>
              <RequestId>18e0ac39-3776-11df-84c0-b93cc1666b84</RequestId> 
            </ResponseMetadata>
          </UnsubscribeResponse>
        RESPONSE
        
        @regexp = %r{/?Action=Unsubscribe}
      end
      
      
      it 'should be able to remove the subscriber' do
        @time_stub.should_receive(:iso8601).and_return(123)
        Time.stub(:now).and_return(@time_stub)
        
        stub_http_request(:get, @regexp).to_return(:body => @data,
                                                    :status => 200,
                                                    :headers => {'Content-Type' => 'text/xml', 'Connection' => 'close'})

        
        AmazeSNS["MyTopic"].unsubscribe('arn:aws:sns:us-east-1:123456789012:MyTopic:80289ba6-0fd4-4079-afb4-ce8c8260f0ca')
        
        WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
        WebMock.should have_requested(:get, @regexp).once
      end
      
    end
    
    context 'deleting a topic' do
      before :each do
        @delete_data = <<-RESPONSE.gsub(/^ +/, '')
          <DeleteTopicResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
            <ResponseMetadata>
              <RequestId>f3aa9ac9-3c3d-11df-8235-9dab105e9c32</RequestId>
            </ResponseMetadata> 
          </DeleteTopicResponse>
        RESPONSE
        
        @regexp = %r{/?Action=DeleteTopic}
      end
      
      
      it 'should send data to the API' do
        @time_stub.should_receive(:iso8601).and_return(123)
        Time.stub(:now).and_return(@time_stub)
        
        stub_http_request(:get, @regexp).to_return(:body => @delete_data,
                                                   :status => 200,
                                                   :headers => {'Content-Type' => 'text/xml', 'Connection' => 'close'})
        
        @request_id = AmazeSNS["MyTopic"].delete
        @request_id["DeleteTopicResponse"]["ResponseMetadata"]["RequestId"].should == "f3aa9ac9-3c3d-11df-8235-9dab105e9c32"
        
        WebMock.should have_requested(:get, @regexp).once
        WebMock.should have_requested(:get, %r{http://sns.us-east-1.amazonaws.com:80}).once
      end
      
      it 'should remove entry from the topics hash' do
        AmazeSNS.topics.has_key?("MyTopic").should_not be_true
      end
      
    end # end deleting a topic spec
  
    
  end
  
end