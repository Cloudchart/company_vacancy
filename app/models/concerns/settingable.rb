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

  def attributes=(hash)
    hash.each { |key, value| send(:"#{key}=", value) }
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

end
