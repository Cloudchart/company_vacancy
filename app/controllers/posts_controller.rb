class PostsController < ApplicationController  

  before_action :set_post, only: [:update, :destroy]

  authorize_resource

  def index
    respond_to do |format|
      format.html {
        @company = Company.find(params[:company_id])

        pagescript_params(
          company_id: @company.id,
          story_id: @stories.find_by(name: params[:story_name]).try(:id)
        )
      }

      format.json {
        @company = find_company(Company.includes(:roles, :stories))
      }
    end
  end
  
  def show
    @post = Post.includes(:owner).find(params[:id])
    
    respond_to do |format|
      format.json
    end
  end

  def create
    @post = @company.posts.build(post_params)

    if @post.save
      respond_to do |format|
        format.json { render json: @post }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def update
    if @post.update(post_params)
      respond_to do |format|
        format.json { render json: @post }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def destroy
    @post.destroy

    respond_to do |format|
      format.json { render json: :ok }
    end
  end

private

  def post_params
    params.require(:post).permit(:title, :effective_from, :effective_till, :position, :tag_names)
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def find_company(relation)
    relation.find_by(slug: params[:company_id]) || relation.find(params[:company_id])
  end
  
end
