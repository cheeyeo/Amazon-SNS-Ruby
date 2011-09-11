autoload 'Logger', 'logger'

require File.dirname(__FILE__) + "/amaze/topic"
require File.dirname(__FILE__) + "/amaze/subscription"
require File.dirname(__FILE__) + "/amaze/helpers"
require File.dirname(__FILE__) + "/amaze/request"
require File.dirname(__FILE__) + "/amaze/exceptions"
require "eventmachine"
require 'crack/xml'

class AmazeSNS
  
  class CredentialError < ::ArgumentError
    def message
      'Please provide your Amazon keys to use the service'
    end
  end
  
  class << self
    attr_accessor :host, :topics, :skey, :akey, :subscriptions, :logger
    
    def logger
      @logger ||= begin
        log = Logger.new(STDOUT)
        log.level = Logger::INFO
        log
      end
    end
  end
  

  self.host = 'sns.us-east-1.amazonaws.com'
  self.skey = ''
  self.akey=''
  self.topics ||= {}
  self.subscriptions ||= {}
  
  def self.[](topic)
    raise CredentialError unless (!(@skey.empty?) && !(@akey.empty?))
    @topics[topic.to_s] = Topic.new(topic) unless @topics.has_key?(topic)
    @topics[topic.to_s]
  end
  
  
  def self.method_missing(id, *args, &blk)
    case(id.to_s)
    when /^list_(.*)/
      send(:process_query, $1, &Proc.new)
    when /^refresh_(.*)/
      send(:process_query, $1)
    else
      raise NoMethodError
    end
  end
  
  def self.process_query(type,&prc)
    type = type.capitalize
    params = {
      'Action' => "List#{type}",
      'SignatureMethod' => 'HmacSHA256',
      'SignatureVersion' => 2,
      'Timestamp' => Time.now.iso8601, #Time.now.iso8601 makes tests fail
      'AWSAccessKeyId' => @akey
    }
    
    request = Request.new(params)
    request.process
    
    request.callback do |data|
      yield data
    end
    
    request.errback do |err|
      #yield err
      EM.stop
    end
    
  end
  
  def self.default_prc
    prc = Proc.new do |resp|
      parsed_response = Crack::XML.parse(resp.response)
      self.process_response(parsed_response)
      EM.stop
    end
  end
  
  def self.process_data(resp)
    parsed_response = Crack::XML.parse(resp.response)
    self.process_response(parsed_response)
    EM.stop
  end
  
  def self.process_response(resp)
    kind = (resp.has_key?("ListTopicsResponse"))? "Topics" : "Subscriptions"
    cla = (resp.has_key?("ListTopicsResponse"))? "Topic" : "Subscription"

    result = resp["List#{kind}Response"]["List#{kind}Result"]["#{kind}"]
    if result.nil?
      nil
    else
      results = result["member"]
    end
    
    @collection = self.send(kind.downcase)
    
    if !(results.nil?) 
      if (results.instance_of?(Array))
        results.each do |t|
          label = t["TopicArn"].split(':').last.to_s
          unless @collection.has_key?(label)
            case cla
            when "Topic"
              @collection[label] = Topic.new(label,t["TopicArn"])
            when "Subscription"
              @collection[label] = Array.new
              @collection[label] << Subscription.new(t)
            end
            
            #@collection[label] = Kernel.const_get("#{cla}").new(t) # t is a hash
          else
            case cla
            when "Topic"
              @collection[label].arn = t["TopicArn"]
            when "Subscription"
              sub = Subscription.new(t)
              @collection[label] << sub unless  @collection[label].detect{|x| x.subarn == sub.subarn}
            end
          end
        end
      elsif (results.instance_of?(Hash))
         # lone entry results in a hash so parse it that way ...
         label = results["TopicArn"].split(':').last.to_s
         case cla
         when "Topic"
           @collection[label] = Topic.new(label, results["TopicArn"])
         when "Subscription"
           @collection[label] = Subscription.new(results)
         end
      end
    else
      nil
    end # end outer if
  end
  
end