class Pinboard < ActiveRecord::Base
  include Uuidable

  validates_uniqueness_of :title, scope: :user_id, case_sensitive: false
  
  belongs_to :user

end
