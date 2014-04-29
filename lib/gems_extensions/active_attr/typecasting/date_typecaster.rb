module ActiveAttr
  module Typecasting
    class DateTypecaster
      def call(value)
        value.to_date if value.respond_to? :to_date
      rescue NoMethodError, ArgumentError
      end

      # multiparameters support
      # https://github.com/cgriego/active_attr/issues/9
      def call_with_multiparameters(value)
        value = Date.new(value[1], value[2], value[3]) if value.is_a?(Hash)
        call_without_multiparameters(value)
      end
      alias_method_chain(:call, :multiparameters)
      
    end
  end
end
