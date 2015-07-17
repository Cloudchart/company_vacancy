module ActiveRecordExtension

  extend ActiveSupport::Concern

  module ClassMethods
    def has_should_markers(*names)
      names.each do |name|
        define_method("#{name}!") { instance_variable_set("@#{name}", true) }
        define_method("#{name}?") { !!instance_variable_get("@#{name}") }
      end
    end
  end

end

ActiveRecord::Base.send(:include, ActiveRecordExtension)
