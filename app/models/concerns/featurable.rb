module Featurable
  extend ActiveSupport::Concern

  included do
    has_many :features, as: :featurable

    Feature.scopes.keys.each do |scope|
      has_one :"#{scope}_feature", -> { where(scope: Feature.scopes[scope]) }, class_name: Feature.name, as: :featurable
    end

    alias_method :is_featured?, :is_featured
    scope :featured, -> { joins(:features).where(features: { is_active: true }) }
  end

  def is_featured=(is_featured)
    if is_featured == '1'
      Feature.create(featurable: self, is_active: true)
    else
      features.first.try(:destroy)
    end
  end

  def is_featured
    features.any?
  end

end
