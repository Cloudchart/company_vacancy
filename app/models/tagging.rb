class Tagging < ActiveRecord::Base
  include Uuidable

  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true
  belongs_to :user
  
end
