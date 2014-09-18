class Role < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :owner, polymorphic: true

end
