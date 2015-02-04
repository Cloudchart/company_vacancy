module Cloudchart
  EDITABLE_ROLES = [:editor, :unicorn].freeze
  ROLES = ([:admin] + EDITABLE_ROLES).freeze
  RAILS_ADMIN_INCLUDED_MODELS = %w(Company Feature User Token Page Person Tag Interview Story Pinboard Role)
end
