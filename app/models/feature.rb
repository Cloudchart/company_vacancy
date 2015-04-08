class Feature < ActiveRecord::Base
  include Uuidable
  include Admin::Feature

  before_create do
    self.featurable_type ||= 'Pin'
  end

  dragonfly_accessor :image

  # belongs_to :featurable, polymorphic: true
  belongs_to :insight, class_name: 'Pin', foreign_key: :featurable_id, inverse_of: :features

  validates :insight, presence: true

  def assigned_image
    image_stored? ? image : insight.post.pictures.first.try(:image)
  end

  def assigned_title
    title.present? ? title : insight.post.title
  end

end
