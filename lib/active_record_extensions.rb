module ActiveRecordExtensions

  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :touch_or_create_by, :touch_or_create_by!, to: :all

      def has_should_markers(*args)
        args.each do |name|
          define_method("#{name}!") { instance_variable_set("@#{name}", true) }
          define_method("#{name}?") { !!instance_variable_get("@#{name}") }
        end
      end

      def has_bitmask_attributes(attrs_with_types={})
        attrs_with_types.each do |name, types|

          define_singleton_method :"values_for_#{name}" do
            types
          end

          define_singleton_method :"with_#{name.to_s.singularize}" do |type|
            where("#{name}_mask & #{2**types.index(type)} > 0")
          end

          define_method name do
            types.reject { |r| ((send(:"#{name}_mask") || 0) & 2**types.index(r)).zero? }
          end

          define_method :"#{name}=" do |names|
            send(:"#{name}_mask=", (names.map(&:to_sym) & types).map { |r| 2**types.index(r) }.sum)
          end

          define_method :"#{name}?" do |*args|
            if args.empty?
              send(name).any?
            else
              args.each { |type| return false unless send(name).include?(type) }
              true
            end
          end

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
