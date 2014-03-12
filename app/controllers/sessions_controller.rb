class SessionsController < ApplicationController

  def new
    flash.now.alert = warden.message if warden.message.present?
  end


  def create
    sleep 2
    respond_to do |format|

      format.html do
        authenticate_user!
        redirect_to root_url, notice: t('messages.logged_in')
      end

      format.json

    end
  end


  def destroy
    warden.logout(:user)
    redirect_to root_url, notice: t('messages.logged_out')
  end

end
