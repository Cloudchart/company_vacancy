require_dependency "cloud_api/application_controller"

module CloudApi
  class UsersController < CloudApi::ApplicationController

    def me
      @source = User
      @starter = [:find, current_user.id]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    def unicorns
      @source = User
      @starter = current_user.editor? ? [:unicorns] : [:none]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    def show
      @source = User.friendly
      @starter = [:find, params[:id]]

      respond_to do |format|
        format.json { render '/main' }
      end
    end


    def create_unicorn
      user = User.new(full_name: params[:unicorn][:full_name])
      user.roles << Role.new(value: 'unicorn')
      user.save!

      render json: { id: user.id }
    end


  end
end
