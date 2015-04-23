class StoriesController < ApplicationController

  before_action :set_story, only: [:show, :update]

  authorize_resource

  def index
    respond_to do |format|
      format.html { 
        @company = Company.find(params[:company_id])
        pagescript_params(company_id: @company.id)
      }
      
      format.json { 
        @company = find_company(Company.includes(posts: [:stories, :pins])) 
      }
    end
  end

  def show    
    respond_to do |format|
      format.json { render json: @story, root: :story }
    end
  end

  def create
    @story = Company.find(params[:company_id]).stories.build(story_params)

    if @story.save
      respond_to do |format|
        format.json { render json: { id: @story.id } }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def update
    if @story.update(story_params)
      respond_to do |format|
        format.json { render json: { id: @story.id } }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

private

  def story_params
    params.require(:story).permit(:name, :description)
  end

  def set_story
    @story = Story.find(params[:id])
  end

  def find_company(relation)
    relation.find_by(slug: params[:company_id]) || relation.find(params[:company_id])
  end

end
