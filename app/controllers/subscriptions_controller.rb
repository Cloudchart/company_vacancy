class SubscriptionsController < ApplicationController

  def create
    current_user.subscriptions.create!(subscription_params)
    redirect_to :back, notice: t('messages.subscriptions.create')    
  end

  def destroy
    subscription = Subscription.where(user_id: current_user.id, subscribable_id: params[:id]).delete_all
    redirect_to :back, notice: t('messages.subscriptions.destroy')
  end

private
  
  # Only allow a trusted parameter "white list" through.
  def subscription_params
    params.require(:subscription).permit(:subscribable_id, :subscribable_type, types: [:company_page, :vacancies, :events])
  end
  
end
