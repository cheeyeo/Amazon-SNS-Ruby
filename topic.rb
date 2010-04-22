require "request"

class Topic
  attr_accessor :topic, :arn
  
  def initialize(topic, arn='')
    @topic = topic
    @arn = arn
  end
  
  def create
    p "INSIDE CREATE TOPIC OF CLASS TOPIC:\n"
    
    params = {
      'Name' => "#{@topic}",
      'Action' => 'CreateTopic',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
     }
     
     req = Request.new(params)
     response = req.process
     # response will be a hash so deal with it accordingly here ...
     @arn = response["CreateTopicResponse"]["CreateTopicResult"]["TopicArn"]
     
     # no need to call refresh list - just add self into the hash
     AmazeSNS.topics[@topic.to_s] = self
     # AmazeSNS.refresh_list
  end
  
  # delete topic
  def delete
    puts 'INSIDE DELETE TOPIC OF CLASS TOPIC:\n\n'
    
    params = {
      'TopicArn' => "#{arn}",
      'Action' => 'DeleteTopic',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
     }
    
     req = Request.new(params)
     response = req.process
     
     p "RESPONSE FROM DELETE: #{response.inspect}"
    
    # update @topics hash in main class
    AmazeSNS.topics.delete("#{@topic}")
    AmazeSNS.topics.rehash
    # AmazeSNS.refresh_list
  end
  
  # get attributes
  def attrs
    
  end
  
end