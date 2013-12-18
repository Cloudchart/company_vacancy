class SessionsController < ApplicationController
  def new
    flash.now.alert = warden.message if warden.message.present?
  end

  def create
    warden.authenticate!
    redirect_to root_url, notice: t('messages.logged_in')
  end

  def destroy
    warden.logout
    redirect_to root_url, notice: t('messages.logged_out')
  end
end
