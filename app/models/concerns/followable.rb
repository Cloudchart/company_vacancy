module Followable
  extend ActiveSupport::Concern

  included do
    has_many :followers, as: :favoritable, dependent: :destroy, class_name: Favorite.name
  end

end
