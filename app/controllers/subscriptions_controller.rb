class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:update, :destroy]

  def create
    current_user.subscriptions.create!(subscription_params)
    redirect_to :back, notice: t('messages.subscriptions.create')    
  end

  def update
    @subscription.update!(subscription_params)
    redirect_to :back, notice: t('messages.subscriptions.update')    
  end

  def destroy
    @subscription.destroy
    redirect_to :back, notice: t('messages.subscriptions.destroy')
  end

private
  
  # Only allow a trusted parameter "white list" through.
  def subscription_params
    params.require(:subscription).permit(:subscribable_id, :subscribable_type, types: [:company_page, :vacancies, :events])
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

end
