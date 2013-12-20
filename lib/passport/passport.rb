module Passport
  mattr_accessor :models
  @@models = {}

  def self.config(&block)
    block.call(Passport::Config)
  end

end
