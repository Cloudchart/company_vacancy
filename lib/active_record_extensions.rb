module ActiveRecordExtensions

  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :touch_or_create_by, :touch_or_create_by!, to: :all

      def has_should_markers(*names)
        names.each do |name|
          define_method("#{name}!") { instance_variable_set("@#{name}", true) }
          define_method("#{name}?") { !!instance_variable_get("@#{name}") }
        end
      end

      def has_bitmask_attributes(attrs_with_types={})
        attrs_with_types.each do |name, types|
          self.class_eval %Q(
            def self.values_for_#{name}
              #{types}
            end

            def self.with_#{name.to_s.singularize}(type)
              where("#{name}_mask & \#{2**values_for_#{name}.index(type)} > 0")
            end

            def #{name}
              #{types}.reject { |r| ((#{name}_mask || 0) & 2**#{types}.index(r)).zero? }
            end

            def #{name}=(#{name})
              self.#{name}_mask = (#{name}.map(&:to_sym) & #{types}).map { |r| 2**#{types}.index(r) }.sum
            end

            def #{name}?(*types)
              (types & #{name}).any?
            end
          )
        end

      end
    end
  end

  module Relation
    extend ActiveSupport::Concern

    def touch_or_create_by(attributes, &block)
      find_by(attributes).try(:touch) || create(attributes, &block)
    end

    def touch_or_create_by!(attributes, &block)
      find_by(attributes).try(:touch) || create!(attributes, &block)
    end
  end

end

ActiveRecord::Relation.send(:include, ActiveRecordExtensions::Relation)
ActiveRecord::Base.send(:include, ActiveRecordExtensions::Base)
