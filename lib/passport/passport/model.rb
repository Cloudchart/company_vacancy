module Passport
  class Model
    attr_reader :name, :class_name, :strategies, :extensions

    def initialize(name, options)
      @name = name.to_sym
      @class_name = @name.to_s.classify

      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

    end
    
    def to
      ActiveSupport::Dependencies.constantize(@class_name)
    end

    
    class << self
      def find_model(scope)
        scope = case scope
        when Symbol then scope
        when String then scope.underscore.to_sym
        when Class then scope.name.underscore.to_sym
        else scope.class.name.underscore.to_sym
        end

        model = Passport.models[scope]
        raise "No model was found with the given scope: '#{scope}'." unless model

        model
      end
    
    end
    
  end
end
