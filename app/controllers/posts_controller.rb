class PostsController < ApplicationController  

  before_action :set_post, only: [:update, :destroy]
  before_action :set_company, only: [:index, :create]

  authorize_resource

  def index
    # get posts
    posts = @company.posts.includes(:visibilities, :pictures, :paragraphs, :pins, :posts_stories, blocks: :block_identities)

    # reject based on visibility rules
    @posts = if can?(:manage, @company)
      posts
    elsif can?(:update, @company) || can?(:finance, @company)
      posts.reject { |post| post.visibility.try(:value) == 'only_me' }
    else
      posts.reject { |post| post.visibility.try(:value) =~ /only_me|trusted/ }
    end

    # get dependent collections
    dependent_associations = [:visibilities, :pictures, :paragraphs, :blocks, :pins]

    dependent_collections = @posts.inject({}) do |memo, post|
      dependent_associations.each do |association|
        memo[association] ||= []
        memo[association] += post.send(association)
      end

      memo
    end

    # instantiate associations
    dependent_associations.each do |association|
      instance_variable_set("@#{association}", dependent_collections[association])
    end

    # add stories
    @stories = Story.cc_plus_company(@company.id)
    @posts_stories = posts.map(&:posts_stories).flatten

    respond_to do |format|
      format.html { 
        pagescript_params(
          company_id: @company.id,
          story_id: @stories.find_by(name: params[:story_name]).try(:id)
        )
      }
      format.json
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

  def set_company
    @company = find_company(Company.includes(:roles, :stories))
  end

  def find_company(relation)
    relation.find_by(slug: params[:company_id]) || relation.find(params[:company_id])
  end
  
end
