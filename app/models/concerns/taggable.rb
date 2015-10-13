module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
  end

  def tag_names
    tags.map(&:name)
  end

  def tag_names=(names)
    self.tags = names.split(',').reject(&:blank?).uniq.map do |name|
      Tag.where(name: name.parameterize).first_or_create!
    end
  end

end
