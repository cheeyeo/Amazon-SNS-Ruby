require "request"
require "exceptions"

# need to find a way to cache the results in a class wide cache
# 

class Topic
  attr_accessor :topic, :arn, :attrs
  
  def initialize(topic, arn='')
    @topic = topic
    @arn = arn
    @attrs ||= {}
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
  
  # get attributes for topic from remote sns server
  # TopicArn -- the topic's ARN 
  # Owner -- the AWS account ID of the topic's owner 
  # Policy -- the JSON serialization of the topic's access control policy 
  # DisplayName -- the human-readable name used in the "From" field for notifications to email and email-json endpoints 
  
  def attrs
    puts 'INSIDE GET ATTR TOPIC OF CLASS TOPIC:\n\n'
    
    params = {
      'TopicArn' => "#{arn}",
      'Action' => 'GetTopicAttributes',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
     }
    
     #req = Request.new(params)
     #response = req.process 
     
     response = make_request(params)
     
     # {"entry"=>[
     #        {"value"=>"365155214602", "key"=>"Owner"}, 
     #        {"value"=>"{\n\"Version\":\"2008-10-17\",\"Id\":\"us-east-1/365155214602/cars__default_policy_ID\",
              #            \"Statement\" : [{\"Effect\":\"Allow\",\"Sid\":\"us-east-1/365155214602/cars__default_statement_ID\",
    #          \"Principal\" : {\"AWS\": \"*\"},
    #          \"Action\":[\"SNS:GetTopicAttributes\",\"SNS:SetTopicAttributes\",\"SNS:AddPermission\",\"SNS:RemovePermission\",\"SNS:DeleteTopic\",\"SNS:Subscribe\",\"SNS:ListSubscriptionsByTopic\",\"SNS:Publish\",\"SNS:Receive\"],
    #          \"Resource\":\"arn:aws:sns:us-east-1:365155214602:cars\",
    #          \"Condition\" : {\"StringLike\" : {\"AWS:SourceArn\": \"arn:aws:*:*:365155214602:*\"}}
    #          } end inner value
    #          ] end statement
    #          } end outer value ", "key"=>"Policy"}, 
     #        {"value"=>"arn:aws:sns:us-east-1:365155214602:cars", "key"=>"TopicArn"}
     #       ]
     #  }
     
     
     res = response['GetTopicAttributesResponse']['GetTopicAttributesResult']['Attributes']["entry"]
     #p res
     make_hash(res) #res["entry"] is an array of hashes - need to turn it into hash with key value
  end
  
  # subscribe method
  def subscribe(opts)
    raise InvalidOptions unless ( !(opts.empty?) && opts.instance_of?(Hash) )
    
    params = {
      'TopicArn' => "#{arn}",
      'Endpoint' => "#{opts[:endpoint]}",
      'Protocol' => "#{opts[:protocol]}",
      'Action' => 'Subscribe',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
    }
    
    response = make_request(params)
    p response.inspect
    res = response['SubscribeResponse']['SubscribeResult']['SubscriptionArn']
  end
  
  def unsubscribe(id)
    raise InvalidOptions unless ( !(id.empty?) && opts.instance_of?(String) )
    
  end
  
  
  # grabs list of subscriptions for this topic
  def subscriptions
    
  end
  
  # helper method to make calls to SNS by building a request object and executing it
  # returns the response
  def make_request(params)
    req = Request.new(params)
    response = req.process
    response
  end
  
  def make_hash(arr)
    hash = arr.inject({}) do |h, v|
      key = v["key"].to_s
      value = v["value"]
      #p "KEY IS : #{key}"
      #p "VALUE IS : #{ value }"
      h[key] = value
      h
    end
    
    hash
  end
  
  
  
end