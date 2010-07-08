class AmazeSNSRuntimeError < RuntimeError; end
class AmazeSNSError < StandardError; end
class AuthenticationError < AmazeSNSRuntimeError; end

class InvalidOptions < AmazeSNSError
  def message
    'Please supply valid options'
  end
end

class AuthorizationError < AmazeSNSError
  def message
    'You do not have permission to access the resource'
  end
end

class InternalError < AmazeSNSError
  def message
    'An internal service error has occured on the Simple Notification Service'
  end
end

class InvalidParameterError < AmazeSNSError
  def message
    'An invalid parameter is in the request'
  end
end


class NotFoundError < AmazeSNSError
  def message
    'The requested resource is not found'
  end
end