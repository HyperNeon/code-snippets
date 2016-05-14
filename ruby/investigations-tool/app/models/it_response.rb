class ITResponse
  include Enumerable
  attr_accessor :id, :status, :result, :errors

  def initialize(id: nil, status: nil, result: nil, errors: nil)
    @id = id
    @status = status
    @result = result
    @errors = errors
  end
  
  def each(&block)
    @result.each(&block)
  end

  def errors?
    @errors.present?
  end

  def ==(other)
    id == other.id && status == other.status && result == other.result &&
        errors == other.errors
  end
end
