class StoriesController < ApplicationController

  before_action :set_company, only: [:index, :create]

  authorize_resource

  def index
    
  end

  def show
    @story = Story.find(params[:id])
  end

  def create
    @story = @company.stories.build(story_params)

    if @story.save
      respond_to do |format|
        format.json { render json: @story.id }
      end
    else
      respond_to do |format|
        format.json { render json: :fail }
      end
    end
  end

private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def story_params
    params.require(:story).permit(:name)
  end

end
