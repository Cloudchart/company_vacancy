require_dependency "cloud_api/application_controller"

module CloudApi
  class UsersController < CloudApi::ApplicationController

    def me
      @source = User

      @starter = if current_user.slug.present?
        [:find_by, slug: current_user.slug]
      else
        [:find, current_user.id]
      end

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    def unicorns
      @source = User
      @starter = [:unicorns]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

    def show
      @source = User

      @starter = if Cloudchart::Utils.uuid?(params[:id])
        [:find, params[:id]]
      else
        [:find_by, slug: params[:id]]
      end

      respond_to do |format|
        format.json { render '/main' }
      end      
    end

  end
end
