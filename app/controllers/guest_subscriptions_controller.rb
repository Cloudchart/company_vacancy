class GuestSubscriptionsController < ApplicationController

  def create
    @guest_subscription = GuestSubscription.find_or_initialize_by(guest_subscription_params)

    if @guest_subscription.persisted? || @guest_subscription.save
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
    @guest_subscription = GuestSubscription.find(params[:id])
    @guest_subscription.update(is_verified: true)

    respond_to do |format|
      format.json { render json: :ok, status: 200 }
    end
  end

private

  def guest_subscription_params
    params.require(:guest_subscription).permit(:email)
  end

end
