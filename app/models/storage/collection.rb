module Storage

  module Collection


    def self.insights_lambda
      @insights_lambda ||= lambda { |ids|
        Pin.includes(:parent).where(pinboard_id: ids).uniq.reduce({}) do |memo, pin|
          (memo[pin.pinboard_id] ||= []) << (pin.parent.nil? ? pin : pin.parent)
          memo[pin.pinboard_id] = memo[pin.pinboard_id].uniq
          memo
        end
      }
    end


    def self.super_featured_collections(scope)
      Pinboard._super_feature(scope).order([:position, :title]).uniq
    end

    def self.featured_collections(scope)
      Pinboard._common_feature(scope).order([:position, :title]).uniq
    end

    def self.insights(id)
      Storage.fetch(self.insights_lambda, id)
    end

  end

end
