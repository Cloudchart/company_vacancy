module Passport
  class Model
    attr_reader :name, :strategy, :strategy_options

    def initialize(name, options)
      @name = name

      options.symbolize_keys[:strategies].each do |strategy|
        if strategy.is_a?(Hash)
          @strategy = strategy.keys.first
          @strategy_options = strategy[@strategy]
        else
          @strategy = strategy
        end

        klass.send :include, Passport::Models.const_get(@strategy.to_s.classify)
      end
    end

    def klass
      @name.to_s.classify.constantize
    end

    class << self
      def find_model(scope)
        Passport.models[scope.to_sym]
      end

      def find_by_option(object)
        find_model(object.name.underscore.to_sym).strategy_options[:find_by].to_sym
      end
    
    end
    
  end
end
