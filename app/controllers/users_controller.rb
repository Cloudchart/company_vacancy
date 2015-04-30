class UsersController < ApplicationController
  include FollowableController

  before_filter :set_user

  authorize_resource
  
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

    if params[:user].try(:[], :email).nil? || @user.emails.pluck(:address).include?(params_for_subscribe[:email])
      @user.tokens.create! name: :subscription
    else
      email = Email.new(address: params_for_subscribe[:email])

      if email.valid?
        @user.tokens.create! name: :subscription
        token = @user.tokens.create name: 'email_verification', data: { address: email.address }
        CloudProfile::ProfileMailer.verification_email(token).deliver
      else
        errors << :email
      end
    end

    raise ActiveRecord::RecordInvalid.new(@user) unless errors.empty?

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

  def temp_info_block
    @user.tokens.find_by(name: "#{params[:type]}").try(:destroy) if Token::TEMP_INFO_BLOCK_TYPES.include?(params[:type].to_sym)

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
    default_fields = [:full_name, :avatar, :remove_avatar, :occupation, :company]
    conditional_fields = []
    conditional_fields << :twitter if @user.try(:unicorn?) && current_user.try(:editor?)
    default_fields + conditional_fields
  end

end
