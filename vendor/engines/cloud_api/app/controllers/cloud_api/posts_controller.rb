require_dependency "cloud_api/application_controller"

module CloudApi
  class PostsController < CloudApi::ApplicationController

    def show
      @source   = Post
      @starter  = [:find, params[:id]]

      respond_to do |format|
        format.json { render '/main' }
      end
    end

  end
end
