class PostsController < ApplicationController  

  # before_action :set_post
  before_action :set_company, only: [:index, :create]

  authorize_resource

  def index
    @posts = @company.posts.includes(blocks: :block_identities)

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

private

  def post_params
    params.require(:post).permit(:title, :cover, :published_at)
  end

  def set_post
  end

  def set_company
    @company = Company.find(params[:company_id])
  end
  
end
