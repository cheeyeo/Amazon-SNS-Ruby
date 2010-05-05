require "rubygems"
require "request"
require "exceptions"
require "eventmachine"


class Topic
  
  attr_accessor :topic, :arn, :attrs

  #def initialize(topic, arn='')
  def initialize(args)
    # @topic = topic
    # @arn = arn
    @topic = args["TopicArn"].split(':').last.to_s
    @arn = args["TopicArn"]
    @attrs ||= {}
  end
  
  def generate_request(params,&blk)
    req_options={}
    req_options[:on_success] = blk if blk
    Request.new(params, req_options).process
  end
  
  # for running th EM loop w/o repetitions
  def reactor(&blk)
    EM.run do
      instance_eval(&blk)
    end
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
     
     reactor{
       generate_request(params) do |response|
         parsed_response = Crack::XML.parse(response.response)
         @arn = parsed_response["CreateTopicResponse"]["CreateTopicResult"]["TopicArn"]
         AmazeSNS.topics[@topic.to_s] = self # add to hash
         AmazeSNS.topics.rehash
         EM.stop
       end
     }
    
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
    
     reactor{
       generate_request(params) do |response|
         parsed_response = Crack::XML.parse(response.response)
         #p "RESPONSE FROM DELETE: #{parsed_response.inspect}"
         # update @topics hash in main class
         AmazeSNS.topics.delete("#{@topic}")
         AmazeSNS.topics.rehash
         EM.stop
        end
      }
    
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
 
     reactor{
       generate_request(params) do |response|
         parsed_response = Crack::XML.parse(response.response)
         p "RESPONSE FROM ATTRS: #{parsed_response.inspect}"  
         res = parsed_response['GetTopicAttributesResponse']['GetTopicAttributesResult']['Attributes']["entry"]
         make_hash(res) #res["entry"] is an array of hashes - need to turn it into hash with key value
         EM.stop
        end
     }
     
  end
  
  def set_attrs(opts)
    
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
    
    reactor{
      generate_request(params) do |response|
        parsed_response = Crack::XML.parse(response.response)
        #p "#{parsed_response.inspect}"
        res = parsed_response['SubscribeResponse']['SubscribeResult']['SubscriptionArn']
        return res
        #p "SUBSCRIPTION RESULT: #{res}"
        EM.stop
      end
    }
    
  end
  
  def unsubscribe(id)
    raise InvalidOptions unless ( !(id.empty?) && id.instance_of?(String) )
    
    params = {
      'SubscriptionArn' => "#{id}",
      'Action' => 'Unsubscribe',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
    }
    
    reactor{
      generate_request(params) do |response|
        parsed_response = Crack::XML.parse(response.response)
        res = parsed_response['UnsubscribeResponse']['ResponseMetadata']['RequestId']
        #p "UN-SUBSCRIPTION RESULT: #{res}"
        return res
        EM.stop
      end
    }
  end
  
  
  # grabs list of subscriptions for this topic only
  def subscriptions
    params = {
      'TopicArn' => "#{arn}",
      'Action' => 'ListSubscriptionsByTopic',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
    }
    
    reactor{
       generate_request(params) do |response|
         #p "response: #{response.response}"
         parsed_response = Crack::XML.parse(response.response)
         #p "parsed response: #{parsed_response.inspect}"
         arr = parsed_response['ListSubscriptionsByTopicResponse']['ListSubscriptionsByTopicResult']['Subscriptions']['member'] unless (parsed_response['ListSubscriptionsByTopicResponse']['ListSubscriptionsByTopicResult']['Subscriptions'].nil?)
                 
         #p "ARR: #{arr.inspect}"
         if !(arr.nil?) && (arr.instance_of?(Array))
           #temp fix for now
           nh = arr.inject({}) do |h,v|
             key = v["SubscriptionArn"].to_s
             value = v
             h[key.to_s] = value
             h
           end
         elsif !(arr.nil?) && (arr.instance_of?(Hash))
           # to deal with one subscription issue
           nh = {}
           key = arr["SubscriptionArn"]
           arr.delete("SubscriptionArn")
           nh[key.to_s] = arr
         end
         
         #puts "NEW HASH IS: #{nh.inspect}"
         return nh
         EM.stop
       end
    }

  end
  
  
  def add_permission(opts)   
  end
  
  def remove_permission(opts)
  end
  
  
  def publish!(msg, subject='')
    p "INSIDE PUBLISH METHOD"
    raise InvalidOptions unless ( !(msg.empty?) && msg.instance_of?(String) )
  
    params = {
      'Subject' => "My First Message",
      'TopicArn' => "#{arn}",
      "Message" => "#{msg}",
      'Action' => 'Publish',
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601,
      'AWSAccessKeyId' => AmazeSNS.akey
    }
    
    reactor{
      generate_request(params) do |response|
        parsed_response = Crack::XML.parse(response.response)
        res = parsed_response['PublishResponse']['PublishResult']['MessageId']
        return res
        EM.stop
      end
    }

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