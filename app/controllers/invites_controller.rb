class InvitesController < ApplicationController

  authorize_resource class: :invite

  def index
    # maybe list invites based on activities?
  end

  def create
    @user = User.new(user_params)

    if @user.save
      Activity.track(current_user, 'invite', @user)

      respond_to do |format|
        format.json { render json: { id: @user.uuid } }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @user.errors }, status: 422 }
      end
    end
  end

  def email
    @user = User.find(params[:id])
    @email_template = EmailTemplate.new(email_template_params)

    if @email_template.valid?
      UserMailer.custom_invite(@user, @email_template)

      respond_to do |format|
        format.json { render json: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @email_template.errors }, status: 422 }
      end
    end
  end

private

  def user_params
    params.require(:user).permit(:twitter)
  end

  def email_template_params
    params.require(:email_template).permit(:email, :subject, :body)
  end

end
