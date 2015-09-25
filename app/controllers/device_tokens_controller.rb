class DeviceTokensController < ApplicationController

  before_action :set_device_token
  authorize_resource

  def create
    if @device_token.persisted?
      render json: :ok, status: 200
    elsif @device_token.save
      render json: :ok, status: 201
    else
      render json: { errors: @device_token.errors }, status: 412
    end
  end

private

  def device_token_params
    params.require(:device_token).permit(:value)
  end

  def set_device_token
    @device_token = case action_name
    when 'create'
      current_user.device_tokens.find_or_initialize_by(device_token_params)
    end
  end

end
