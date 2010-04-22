require "rubygems"
require 'http_client'
require 'crack/xml'

require "helpers"
require "exceptions"

# use eventmachine to handle async requests

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
      
      response = HttpClient.get "#{AmazeSNS.host}?#{querystring2}"
      # error checking here....
      parsed_response = Crack::XML.parse(response)
      #p parsed_response.inspect
      return parsed_response
  end
  
end