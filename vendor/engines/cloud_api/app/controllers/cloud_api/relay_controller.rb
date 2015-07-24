require_dependency "cloud_api/application_controller"

module CloudApi
  class RelayController < CloudApi::ApplicationController

    def fetch
      @source   = params[:type].constantize
      @starter  = [:find, params[:id]]


      shape = BaseShape.shape(Viewer.find(current_user.id), { full_name: {}, url: {}, avatar: { url: {} } }, ability: Ability.new(current_user))


      Rails.logger.info { "SHAPE: #{shape.to_json}" }


      respond_to do |format|
        format.json do
          render_cached_main_json(expires_in: 10.minutes)
        end
      end
    end

  end
end
