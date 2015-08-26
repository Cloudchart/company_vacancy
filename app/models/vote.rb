class Vote < ActiveRecord::Base
  include Uuidable

  belongs_to :source, polymorphic: true
  belongs_to :destination, polymorphic: true

end
