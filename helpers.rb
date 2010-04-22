require "rubygems"
require "hmac"
require "hmac-sha2"
require "cgi"
require "time"
require "base64"


# HELPER METHODS
def url_encode(string)
  string = string.to_s
  # It's kinda like CGI.escape, except CGI.escape is encoding a tilde when
  # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
  return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
end
  
def canonical_querystring(params)
  # I hope this built-in sort sorts by byte order, that's what's required. 
  values = params.keys.sort.collect {|key|  [url_encode(key), url_encode(params[key])].join("=") }

  return values.join("&")
end


def hash_to_query(hash)
  hash.collect do |key, value|

    url_encode(key) + "=" + url_encode(value)

  end.join("&")
end
