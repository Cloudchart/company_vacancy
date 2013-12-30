module Passport
  class Model
    attr_reader :name, :class_name, :strategies

    def initialize(name, options)
      @name = name.to_sym
      @class_name = @name.to_s.classify
      @strategies = options.symbolize_keys![:strategies]
    end

    def to
      ActiveSupport::Dependencies.constantize(@class_name)
    end

    class << self
      def find_model(scope)
        Passport.models[scope.to_sym]
      end
    
    end
    
  end
end
