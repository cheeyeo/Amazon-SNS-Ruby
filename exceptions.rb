class AmazeSNSError < StandardError; end

class InvalidOptions < AmazeSNSError
  def message
    'Please supply valid options'
  end
end
