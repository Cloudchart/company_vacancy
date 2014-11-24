module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings
  end

  def tag_names
    tags.order('taggings.created_at').pluck(:name)
  end

  def tag_names=(names)
    self.tags = names.split(',').reject(&:blank?).map do |name|
      Tag.where(name: name.parameterize).first_or_create!
    end
  end

end
