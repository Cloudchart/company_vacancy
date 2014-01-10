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
        scope = if scope.is_a?(Class)
          scope.name.underscore.to_sym
        else
          scope.to_sym
        end

        model = Passport.models[scope]
        raise "No model was found with the given scope: '#{scope}'." unless model

        model
      end
    
    end
    
  end
end
