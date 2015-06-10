module Preloadable

  extend ActiveSupport::Concern


  def self.preload(records, local_cache, *associations)
    keyed_associations = associations.extract_options!
    keyed_associations.each { |key, value| associations << { key => value } }
    associations.each do |association|
      unless local_cache.include?(association)
        ActiveRecord::Associations::Preloader.new.preload(records, association)
        local_cache << association
      end
    end
  end


  module ClassMethods

    def acts_as_preloadable(method_name, *associations)
      define_singleton_method :"preload_#{method_name}" do |records, cache|
        Preloadable::preload(records, cache, *associations)
      end
    end

  end


end
