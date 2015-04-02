class PostsController < ApplicationController

  before_action :set_company, only: [:index, :create]
  before_action :set_post, only: [:show, :update, :destroy]

  load_and_authorize_resource except: [:create]

  after_action :create_intercom_event, only: :create

  def index
    respond_to do |format|
      format.html {
        pagescript_params(
          company_id: @company.id,
          story_id: Story.cc_plus_company(@company.id).find_by(name: params[:story_name]).try(:id)
        )
      }

      format.json
    end
  end

  def fetch
    respond_to do |format|
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html { 
        @company = @post.company
        pagescript_params(id: @post.id, company_id: @company.id)
      }
      format.json
    end
  end

  def create
    if blank_post = @company.posts.select { |post| post.created_at == post.updated_at }.first
      respond_to do |format|
        format.json { render json: blank_post }
      end
    else
      @post = @company.posts.build(post_params)
      authorize! :create, @post

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
    params.require(:post).permit(:title, :effective_from, :effective_till, :position)
  end

  def set_post
    @post = Post.includes(:owner, :visibilities).find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def create_intercom_event
    return unless should_perform_sidekiq_worker? && @post.try(:valid?)

    IntercomEventsWorker.perform_async('created-post', current_user.id, post_id: @post.id)
  end

end
