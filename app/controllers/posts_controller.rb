class PostsController < ApplicationController  

  before_action :set_post, only: [:update, :destroy]
  before_action :set_company, only: [:index, :create]

  authorize_resource

  def index
    posts = @company.posts.includes(:visibility, :pictures, :paragraphs, blocks: :block_identities)

    @posts = if can?(:manage, @company)
      posts
    elsif can?(:update, @company) || can?(:finance, @company)
      posts.reject { |post| post.visibility.try(:value) == 'only_me' }
    else
      posts.reject { |post| post.visibility.try(:value) =~ /only_me|trusted/ }
    end

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
    @company = find_company(Company.includes(:roles))
  end

  def find_company(relation)
    relation.find_by(slug: params[:company_id]) || relation.find(params[:company_id])
  end
  
end
