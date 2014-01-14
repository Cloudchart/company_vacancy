module Passport
  class FailureApp < ActionController::Metal
    include ActionController::Redirecting
    include Rails.application.routes.url_helpers

    delegate :flash, to: :request

    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def respond
      flash[:alert] = warden_message
      redirect_to login_url
    end

    protected

      def warden
        env['warden']
      end

      def warden_options
        env['warden.options']
      end

      def warden_message
        @message ||= warden.message || warden_options[:message]
      end

  end
end
