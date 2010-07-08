
require 'crack/xml'

require File.dirname(__FILE__) + "/helpers"
require File.dirname(__FILE__) + "/exceptions"

require 'em-http'


class Request
  
  attr_accessor :params, :options, :httpresponse
  
  def initialize(params, options={})
    @params = params
    @options = options
  end
  
  def process2
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
     response = HttpClient.get "#{AmazeSNS.host}?#{querystring2}"
     parsed_response = Crack::XML.parse(response)
     return parsed_response
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
      
      @httpresponse ||=  http_class.new("http://#{AmazeSNS.host}/?#{querystring2}").send(:get)
      @httpresponse.callback{ success_callback }
      @httpresponse.errback{ error_callback }
      nil
  end
  
  def http_class
    EventMachine::HttpRequest
  end
  
  
  def success_callback
    case @httpresponse.response_header.status
     when 403
       raise AuthorizationError
     when 500
       raise InternalError
     when 400
       raise InvalidParameterError
     when 404
       raise NotFoundError
     else
       call_user_success_handler
     end #end case
  end
  
  def call_user_success_handler
    @options[:on_success].call(httpresponse) if options[:on_success].respond_to?(:call)
  end
  
  def error_callback
    EventMachine.stop
    raise AmazeSNSRuntimeError.new("A runtime error has occured: status code: #{@httpresponse.response_header.status}")
  end
  
  
end