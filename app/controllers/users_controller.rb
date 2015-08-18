class UsersController < ApplicationController
  include FollowableController

  before_action :redirect_to_twitter_auth, only: :feed
  before_action :set_user, only: [:show, :update, :subscribe, :unsubscribe]

  authorize_resource

  after_action :call_page_visit_to_slack_channel, only: [:show, :feed]
  after_action :mark_friends_user, only: [:follow, :unfollow]

  def show
    respond_to do |format|
      format.html
    end
  end

  def feed
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

  def subscribe
    errors = []

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

    @user.tokens.find_or_create_by!(name: :subscription)

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
    case action_name
    when 'show'
      page_title = current_user == @user ? 'his profile' : "#{@user.full_name_or_twitter}'s profile"
      page_url = main_app.user_url(@user)
    when 'feed'
      page_title = 'Feed'
      page_url = main_app.feed_url
    end

    post_page_visit_to_slack_channel(page_title, page_url)
  end

  def redirect_to_twitter_auth
    if current_user.guest? && session[:previous_path] != '/logout'
      redirect_to main_app.twitter_auth_path
    end
  end

  def mark_friends_user
    if @object
      friends_user = current_user.friends_users.find_or_create_by(friend: @object)
      friends_user.data = { scope: :app }
      friends_user.save
    end
  end

end
