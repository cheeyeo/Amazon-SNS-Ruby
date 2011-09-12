require "rubygems"
require 'crack/xml'

require File.dirname(__FILE__) + "/helpers"
require File.dirname(__FILE__) + "/exceptions"

require 'em-http'


class Request
  include EM::Deferrable
  
  attr_accessor :params, :httpresponse
  
  def initialize(params)
    @params = params
  end
  
  def process
    query_string = canonical_querystring(@params)

string_to_sign = "GET
#{AmazeSNS.host}
/
#{query_string}"
                
      hmac = HMAC::SHA256.new(AmazeSNS.skey)
      hmac.update( string_to_sign )
      signature = Base64.encode64(hmac.digest).chomp
      
      params['Signature'] = signature
      querystring2 = params.collect { |key, value| [url_encode(key), url_encode(value)].join("=") }.join('&') # order doesn't matter for the actual request
      
      unless defined?(EventMachine) && EventMachine.reactor_running?
        raise AmazeSNSRuntimeError, "In order to use this you must be running inside an eventmachine loop"
      end
      
      require 'em-http' unless defined?(EventMachine::HttpRequest)
      
      @httpresponse ||= http_class.new("http://#{AmazeSNS.host}/?").get({
        :query => querystring2, :timeout => 2
      })
      
      # a bit misleading but call is still successful even if the status code is not 200
      @httpresponse.callback{ success_callback } 
      @httpresponse.errback{ error_callback } 
  end
  
  def http_class
    EventMachine::HttpRequest
  end
  
  
  def success_callback
    case @httpresponse.response_header.status
     when 200
       self.succeed(@httpresponse)
     when 403
       raise AuthorizationError
     when 500
       raise InternalError
     when 400
       raise InvalidParameterError
     when 404
       raise NotFoundError
     else
       self.fail("Call to Amazon SNS API failed")
     end #end case
  end
  
  def call_user_success_handler
    #puts "#{@options[:on_success]}"
    @options[:on_success].call(@httpresponse) if @options[:on_success].respond_to?(:call)
    #self.succeed(@httpresponse)
  end
  
  def error_callback
    EventMachine.stop
    raise AmazeSNSRuntimeError.new("A runtime error has occured: status code: #{@httpresponse.response_header.status}")
  end
  
  
end