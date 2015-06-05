module Preloadable


  def self.preload(records, local_cache, *associations)
    keyed_associations = associations.extract_options!
    keyed_associations.each { |key, value| associations << { key => value } }
    associations.each do |association|
      unless local_cache.include?(association)
        ActiveRecord::Associations::Preloader.new.preload(records, association)
      end
    end
  end


end
