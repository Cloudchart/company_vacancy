module Preloadable::Pin
  extend ActiveSupport::Concern


  included do
    include Preloadable

    acts_as_preloadable :connected_collections, :pinboard, children: :pinboard

    def connected_collections
      children.map(&:pinboard).concat([pinboard])
    end
  end

end
