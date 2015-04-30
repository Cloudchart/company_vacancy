class CloudMutation


  class << self

    def returns(*fields)
      @returns ||= []

      fields.each { |field| @returns << field.to_sym }
      @returns.uniq! if fields.size > 0

      @returns
    end


    def expects(*fields)
      @expects ||= []

      fields.each { |field| @expects << field.to_sym }
      @expects.uniq! if fields.size > 0

      @expects
    end

  end


  def initialize(request)
    @request = request
  end


  def returns
    self.class.returns
  end


  def expects
    self.class.expects
  end


  def params
    @request.params.permit(expects)
  end


  def execute!
    raise NotImplementedError.new("You must implement execute! method in #{self.class.name}")
  end


end
