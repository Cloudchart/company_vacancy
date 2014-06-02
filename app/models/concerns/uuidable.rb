module Uuidable
  extend ActiveSupport::Concern

  included do
    self.primary_key = :uuid
    before_create :generate_uuid
  end

  private

    def generate_uuid
      self.id = SecureRandom.uuid unless self.id.present?
    end

end
