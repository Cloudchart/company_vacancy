class Pin < ActiveRecord::Base
  include Uuidable
  
  belongs_to  :user
  belongs_to  :parent,    class_name: Pin.name
  belongs_to  :pinboard
  belongs_to  :pinnable,  polymorphic: true
  
  has_many    :children,  class_name: Pin.name, foreign_key: :parent_id
end
