class UsersController < ApplicationController
  include FollowableController

  before_action :set_user

  authorize_resource

  before_action :call_page_visit_to_slack_channel, only: :show

  def show
    respond_to do |format|
      format.html
    end
  end

  def update
    @user.should_validate_name!
    @user.update! params_for_update

    respond_to do |format|
      format.json { render json: { id: @user.uuid } }
    end
  
  rescue ActiveRecord::RecordInvalid

    respond_to do |format|
      format.json { render json: { errors: @user.errors }, status: 422 }
    end
  end

  def settings
    respond_to do |format|
      format.html
    end
  end

  def subscribe
    errors = []
    errors << :subscribed if @user.tokens.find_by(name: :subscription)

    if should_verify_email?(@user) && errors.empty?
      email = Email.new(address: params_for_subscribe[:email])

      if email.valid?
        token = @user.tokens.where(name: :email_verification).select { |token| token.data[:address] == email.address }.first ||
                @user.tokens.create(name: :email_verification, data: { address: email.address })
        
        CloudProfile::ProfileMailer.verification_email(token).deliver
      else
        errors << :email
      end
    end

    raise ActiveRecord::RecordInvalid.new(@user) unless errors.empty?

    @user.tokens.create! name: :subscription

    render json: :ok

  rescue ActiveRecord::RecordInvalid

    render json: { errors: errors }, status: 422
  end

  def unsubscribe
    @user.tokens.find_by(name: :subscription).try(:destroy)

    respond_to do |format|
      format.json { render json: :ok }
    end
  end

private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def params_for_update
    params.require(:user).permit(fields_for_update)
  end

  def params_for_subscribe
    params.require(:user).permit(:email)
  end

  def fields_for_update
    fields = [:full_name, :avatar, :remove_avatar, :occupation, :company]
    fields << :twitter if @user.try(:unicorn?) && current_user.try(:editor?)
    fields
  end

  def should_verify_email?(user)
    email = params[:user].try(:[], :email)
    email && !user.emails.map(&:address).include?(email)
  end

  def call_page_visit_to_slack_channel
    page_title = current_user == @user ? 'his profile' : "#{@user.full_name_or_twitter}'s profile"
    post_page_visit_to_slack_channel(page_title, main_app.user_url(current_user))
  end

end
