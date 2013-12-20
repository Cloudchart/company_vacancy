module Passport
  module Config
    def self.model(name, options)
      Passport.models[name.to_sym] = Passport::Model.new(name.to_sym, options)
    end

  end
end
