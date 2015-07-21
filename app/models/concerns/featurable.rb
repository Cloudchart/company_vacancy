module Featurable
  extend ActiveSupport::Concern

  included do
    has_one :feature, as: :featurable
    alias_method :is_featured?, :is_featured
    scope :featured, -> { joins(:feature).where(features: { is_active: true }) }
  end

  def is_featured=(is_featured)
    if is_featured == '1'
      Feature.create(featurable: self)
    else
      feature.try(:destroy)
    end
  end

  def is_featured
    feature.present?
  end

end
