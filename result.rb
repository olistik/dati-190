module Result
  class BaseResult
    attr_reader :code, :data

    def initialize(code: :ok, data:, success: true)
      @code = code
      @data = data
      @success = success
    end

    def success?
      @success == true
    end

    def error?
      !success?
    end
  end

  SELF_MODULE = self

  def success(data: nil, code: :ok)
    SELF_MODULE.success(data, code: code)
  end

  def self.success(data: nil, code: :ok)
    BaseResult.new(code: code, data: data)
  end

  def error(data: nil, code: :ko)
    SELF_MODULE.error(data, code: code)
  end

  def self.error(data: nil, code: :ko)
    BaseResult.new(code: code, data: data, success: false)
  end
end

