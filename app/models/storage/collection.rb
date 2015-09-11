module Storage

  module Collection


    def self.insights_lambda
      @insights_lambda ||= lambda { |ids|
        Pin.insights.where(pinboard_id: ids).uniq.to_a.group_by { |item| item.pinboard_id }
      }
    end


    def self.featured_collections(scope)
      Pinboard._common_feature(scope).order([:position, :title]).uniq
    end

    def self.insights(id)
      Storage.fetch(self.insights_lambda, id)
    end

  end

end
