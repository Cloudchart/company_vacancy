module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings
  end

  # module ClassMethods
  # end

  def tag_list
    # tags.pluck(:name).join(', ')
    tags.map { |tag| { id: tag.id, name: tag.name } }
  end

  def tag_list=(names)
    self.tags = names.split(',').reject(&:blank?).map do |name|
      Tag.where(name: name.parameterize).first_or_create!
    end
  end

end
