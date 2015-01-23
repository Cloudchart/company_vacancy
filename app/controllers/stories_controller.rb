class StoriesController < ApplicationController

  before_action :set_company, only: [:index, :create]
  before_action :set_story, only: [:update]

  authorize_resource

  def index    
  end

  def create
    @story = @company.stories.build(story_params)

    if @story.save
      respond_to do |format|
        format.json { render json: { uuid: @story.id } }
      end
    else
      respond_to do |format|
        format.json { render json: :fail }
      end
    end
  end

  def update
    if @story.update(story_params)
      respond_to do |format|
        format.json { render json: @story, root: :story }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

private

  def set_story
    @story = Story.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def story_params
    params.require(:story).permit(:name, :description)
  end

end
