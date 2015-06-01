module Featurable
  extend ActiveSupport::Concern

  included do
    has_one :feature, as: :featurable
    # alias_method :is_featured?, :is_featured
    scope :featured, -> { joins(:feature) }
  end

  def is_featured=(is_featured)
    if is_featured == '1'
      Feature.create(insight: self)
    else
      feature.try(:destroy)
    end
  end

  def featured?
    feature.present?
  end

  # def is_featured
  #   featured?
  # end
end
