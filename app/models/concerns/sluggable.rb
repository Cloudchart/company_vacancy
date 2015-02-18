module Sluggable
  extend ActiveSupport::Concern

  included do
    validates :slug, uniqueness: true, allow_blank: true
  end

  module ClassMethods
    def find(*args)
      return super if Cloudchart::Utils.uuid?(args.first)
      find_by(slug: args.first) || super
    end
  end

  def to_param
    slug.present? ? slug : super
  end

end
