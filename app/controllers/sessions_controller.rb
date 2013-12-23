# TODO: move to passport lib
class SessionsController < ApplicationController
  def new
    flash.now.alert = warden.message if warden.message.present?
  end

  def create
    warden.authenticate!(:password, scope: :user)
    redirect_to root_url, notice: t('messages.logged_in')
  end

  def destroy
    warden.logout(:user)
    redirect_to root_url, notice: t('messages.logged_out')
  end
end
