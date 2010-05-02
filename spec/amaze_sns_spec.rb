require File.dirname(__FILE__) + '/spec_helper.rb'

describe AmazeSNS do

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
 
  describe 'calling refresh_list' do
    before do
       AmazeSNS.akey = 'xxxxx'
       AmazeSNS.skey = 'xxxxx'
     
      # @hash = {}
      #      @hash["topic_1"] = Topic.new('topic_1', 'arn:aws:sns:us-east-1:365155214602:topic_1')
      #      @hash["topic_2"] = Topic.new('topic_2', 'arn:aws:sns:us-east-1:365155214602:topic_2')
      #      @hash["topic_3"] = Topic.new('topic_3', 'arn:aws:sns:us-east-1:365155214602:topic_3')
      #      #AmazeSNS.stub!(:refresh_list).and_return(@hash)
      #      AmazeSNS.stub!(:list_topics).and_return(@hash)
      #      EM.stub!(:run).and_return(true)
    end
    
    it 'should return a hash of topics' do
      AmazeSNS.refresh_list
      AmazeSNS.topics.empty?.should == false
    end
    
    it 'should contain a list of topics in the hash' do
      AmazeSNS.topics.values.first.should be_kind_of(Topic)
      AmazeSNS.topics.values.first.topic.should == "29steps_products"
    end
    
  end
 
end # end outer describe


