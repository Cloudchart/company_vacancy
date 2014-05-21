class SubscriptionsController < ApplicationController

  def create
    subscription = Subscription.new(subscription_params)
    subscription.user = current_user
    subscription.types = OpenStruct.new(subscription_params[:types])
    subscription.save!
    # Rails.logger.info("#{'*'*1000} #{subscription.types.vacancies}")
    # unless current_user.subscriptions.map(&:subscribable_id).include?(@company.id)
    #   current_user.subscriptions.create(subscribable: @company)
    # end
    redirect_to :back, notice: t('messages.subscriptions.create')    
  end

  def destroy
    subscription = Subscription.find(params[:id]).destroy
    redirect_to :back, notice: t('messages.subscriptions.destroy')
  end

private
  
  # Only allow a trusted parameter "white list" through.
  def subscription_params
    params.require(:subscription).permit(:subscribable_id, :subscribable_type, types: [:company_info, :vacancies, :events])
  end
  
end
