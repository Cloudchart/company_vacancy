class GuestSubscriptionsController < ApplicationController

  load_and_authorize_resource

  def create
    @guest_subscription = GuestSubscription.find_or_initialize_by(guest_subscription_params)

    if @guest_subscription.persisted? || @guest_subscription.save
      UserMailer.guest_subscription(@guest_subscription).deliver

      if should_perform_sidekiq_worker?
        SlackWebhooksWorker.perform_async('guest_subscribed', current_user.id,
          email_address: @guest_subscription.email,
          request_env: request.env
        )
      end

      respond_to do |format|
        format.json { render json: :ok, status: 200 }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @guest_subscription.errors }, status: 422 }
      end
    end
  end

  def verify
    @guest_subscription.update(is_verified: true)

    redirect_to main_app.root_url
  end

private

  def guest_subscription_params
    params.require(:guest_subscription).permit(:email)
  end

end
