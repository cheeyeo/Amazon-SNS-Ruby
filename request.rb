require "rubygems"
require 'http_client'
require 'crack/xml'

require "helpers"
require "exceptions"

# use eventmachine to handle async requests
require 'em-http'


class Request
  
  attr_accessor :params
  
  def initialize(params)
    @params = params
  end
  
  def process
    #p "inside process method of request"
    query_string = canonical_querystring(@params)
    #p "QUERY STRING: #{query_string}"
            
string_to_sign = "GET
#{AmazeSNS.host}
/
#{query_string}"
                
      hmac = HMAC::SHA256.new(AmazeSNS.skey)
      hmac.update( string_to_sign )
      signature = Base64.encode64(hmac.digest).chomp
      
      params['Signature'] = signature
      #p params.inspect

      querystring2 = params.collect { |key, value| [url_encode(key), url_encode(value)].join("=") }.join('&') # order doesn't matter for the actual request
      #p querystring2.inspect 
      #response = HttpClient.get "#{AmazeSNS.host}?#{querystring2}"
      
      
      EM.run{
       @httpresponse =  EventMachine::HttpRequest.new("http://#{AmazeSNS.host}/?#{querystring2}").get
        
       @httpresponse.callback{
         case @httpresponse.response_header.status
         when 403
           raise AuthorizationError
         when 500
           raise InternalError
         when 400
           raise InvalidParameterError
         else
           #p "INSIDE CALLBACK"
           parsed_response = Crack::XML.parse(@httpresponse.response)
           #p "PARSED RESPONSE: #{parsed_response}"
           return parsed_response
         end #end case
         
         EM.stop
       }
        
       @httpresponse.errback{ error_callback }
        
      } # end EM.run
      
      nil
  end
  

  def error_callback
    EM.stop
    # check for response codes here and issue exceptions accordingly
    #p "INSIDE ERROR CALLBACK"
    #p "STATUS CODE #{@httpresponse.response_header.status}"
    raise AmazeSNSRuntimeError.new("A runtime error has occured: status code: #{@httpresponse.response_header.status}")
  end
  
  
end