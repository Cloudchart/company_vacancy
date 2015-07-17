require_dependency "cloud_api/application_controller"

module CloudApi
  class SearchController < CloudApi::ApplicationController

    respond_to :json

    def index

      data = case params[:type]
      when 'Unicorn'
        search_unicorns
      else
        []
      end

      respond_with data, root: false
    end


    private


    def search_unicorns
      if current_user.editor?
        query = params[:query] + '%'
        User.unicorns.where { first_name.like(query) | last_name.like(query) }.map { |unicorn| { id: unicorn.id, full_name: unicorn.full_name }}
      else
        []
      end

    end


  end
end
