require File.dirname(__FILE__) + '/spec_helper.rb'

describe Topic do
  before do
    @topic = Topic.new('my_test_topic', 'arn:123456')
  end
  
  describe 'in its initial state' do
    it 'should be an instance of Topic class' do
      @topic.should be_kind_of(Topic)
    end
    
    it 'should return the topic name and arn when requested' do
      @topic.topic.should == 'my_test_topic'
      @topic.arn.should == 'arn:123456'
    end
    
  end
  
  describe 'when creating a topic' do
  end
  
end