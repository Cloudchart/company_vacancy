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
