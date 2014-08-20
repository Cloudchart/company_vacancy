module Permalinkable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_permalink
    validates :title, presence: true, uniqueness: true
  end

  module ClassMethods
    def find(*args)
      return super if Cloudchart::Utils.is_uuid?(args.first)
      find_by(permalink: args.first) || super
    end
  end

  def to_param
    permalink.present? ? permalink : super
  end

private

  def assign_permalink
    self.permalink = title.downcase.squish.gsub(/\s/, '-')
  end

end
