module JsonSerializable
  extend ActiveSupport::Concern

  module ClassMethods
    def load(json)
      new.from_json(json) rescue new
    end

    def dump(instance)
      instance.to_json
    end
  end

end
