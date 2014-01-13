module Passport::Models
  module Confirmable
    extend ActiveSupport::Concern

    included do
      after_create :create_confirmation_token_and_send_email
    end

    private

      def create_confirmation_token_and_send_email
        token = tokens.create(name: :confirmation)
        # TODO: add confirm@cloudchart.com to verified postmark addresses
        # UserMailer.confirmation_instructions(self).deliver
      end

  end
end
