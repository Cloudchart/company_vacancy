class PostsController < ApplicationController  

  before_action :set_post, only: [:update, :destroy]
  before_action :set_company, only: [:index, :create]

  authorize_resource

  def index
    @posts = @company.posts.includes(:pictures, :paragraphs, blocks: :block_identities)

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
    params.require(:post).permit(:title, :published_at, :tag_names)
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end
  
end
