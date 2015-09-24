module Storage

  module UserStorage


    def self.find_lambda
      @find_lambda ||= lambda { |ids|
        User.find(ids).uniq.reduce({}) do |memo, user|
          memo[user.id] = user
          memo
        end
      }
    end


    def self.find(id)
      Storage.fetch(find_lambda, id)
    end


    def self.featured(scope)
      User.find([
        '07943414-306e-41b3-941a-c4a10a6770bc',
        'e54df86b-eb0f-41b7-b5c7-1c416ffb743e',
        '887221de-65ab-40a4-a880-195584cc44b2',
        # 'ec415e28-5a90-4bb0-a3ac-ccc2d83f6c31',
        '9332eb45-4b03-46ff-ab48-a14cea0116be',
        '747c779b-fcf9-42ca-bf5a-eb14ea342008',
        # '4787b5fb-4f8b-4f27-b967-e9bd052df8d1'
      ])
    end

  end

end
