module Settingable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations
  end

  module ClassMethods
    def load(json)
      new.from_json(json) rescue new
    end

    def dump(instance)
      instance.to_json
    end

    def columns(*args)
      return @columns || {} if args.blank?

      options = args.extract_options!
      
      args.each { |name| options[name] = :string }

      @columns = options.dup

      @columns.each do |name, type|
        attr_reader :"#{name}"
        define_method :"#{name}=" do |value|
          instance_variable_set("@#{name}", type_cast(type, value))
        end
      end

      @columns
    end

  end

  # TODO: why this method is called on show action?
  def attributes=(attributes)
    return if attributes.blank?

    attributes.stringify_keys!
    multi_parameter_attributes = []

    attributes.each do |key, value|
      if key.include?('(')
        multi_parameter_attributes << [ key, value ]
      else
        _assign_attribute(key, value)
      end
    end

    assign_multiparameter_attributes(multi_parameter_attributes) unless multi_parameter_attributes.empty?
  end

  def attributes
    instance_values
  end

  def inspect
    attributes.as_json
  end

  private

    def type_cast(type, value)
      case type
      when :string then value.to_s
      when :integer then value.to_i
      when :date then value.to_date
      end
    end

    def _assign_attribute(key, value)
      send(:"#{key}=", value) if !!self.class.columns[key.to_sym]
    end

    def assign_multiparameter_attributes(pairs)
      attributes = {}

      pairs.each do |multiparameter_name, value|
        attribute_name = multiparameter_name.split("(").first
        attributes[attribute_name] ||= {}

        parameter_value = value.empty? ? nil : type_cast_multiparameter(multiparameter_name, value)
        attributes[attribute_name][find_multiparameter_position(multiparameter_name)] ||= parameter_value
      end

      # TODO: value must be converted inside type_cast method
      attributes.each { |key, value| _assign_attribute(key, value.values.join('-')) }
    end

    def type_cast_multiparameter(multiparameter_name, value)
      multiparameter_name =~ /\([0-9]*([if])\)/ ? value.send("to_" + $1) : value
    end

    def find_multiparameter_position(multiparameter_name)
      multiparameter_name.scan(/\(([0-9]*).*\)/).first.first.to_i
    end

end
