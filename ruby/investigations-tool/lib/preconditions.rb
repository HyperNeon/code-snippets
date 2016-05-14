module Preconditions
  def self.check_not_nil(data, error_message)
    raise error_message if data.nil?
    data
  end
end
