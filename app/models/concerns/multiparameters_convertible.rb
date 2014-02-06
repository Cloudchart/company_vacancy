module MultiparametersConvertible
  extend ActiveSupport::Concern

  def attributes=(attributes)
    super(convert_multiparameters(attributes))
  end

  private

    def convert_multiparameters(attributes)
      multiparameter_attributes = attributes.select { |k, v| k.include?('(') }
      new_attributes = {}

      multiparameter_attributes.each do |multiparameter_name, value|
        attribute_name = multiparameter_name.split('(').first
        new_attributes[attribute_name] ||= {}

        parameter_value = value.empty? ? nil : type_cast_multiparameter(multiparameter_name, value)
        new_attributes[attribute_name][find_multiparameter_position(multiparameter_name)] ||= parameter_value
      end

      attributes.delete_if { |k, v| k.include?('(') }.merge(new_attributes)
    end

    def type_cast_multiparameter(multiparameter_name, value)
      multiparameter_name =~ /\([0-9]*([if])\)/ ? value.send("to_" + $1) : value
    end

    def find_multiparameter_position(multiparameter_name)
      multiparameter_name.scan(/\(([0-9]*).*\)/).first.first.to_i
    end

end
