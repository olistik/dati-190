require_relative 'result'

class Promise
  def initialize(value: nil)
    @success = nil
    @catch = nil
    @steps = []
    @result = Result.success(data: value)
  end

  def then(data: true, &blk)
    @steps.push({data: data, body: blk})
    self
  end

  def success(&blk)
    @success = blk
    self
  end

  def catch(&blk)
    @catch = blk
    self
  end

  def resolve
    has_error = @steps.find do |step|
      value = step[:data] ? @result.data : @result
      @result = step[:body].call(value)
      if !@result.kind_of?(Result::BaseResult)
	      @result = Result.success(data: @result)
      end
      @result.error?
    end
    @result = if has_error
      @catch ? @catch.call(@result) : @result
    else
      @success ? @success.call(@result) : @result
    end
    @result
  end
end
