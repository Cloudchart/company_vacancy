class Feature < ActiveRecord::Base
  include Uuidable
  include Admin::Feature

  belongs_to :featurable, polymorphic: true

  validates :featurable, presence: true
end
