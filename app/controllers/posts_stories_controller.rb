class PostsStoriesController < ApplicationController  

  before_action :set_posts_story, only: [:update, :destroy]
  before_action :set_post, only: [:create]

  # TODO:
  # authorize_resource

  def create
    @posts_story = @post.posts_stories.build(posts_story_params)

    if @posts_story.save
      respond_to do |format|
        format.json { render json: @posts_story, root: :posts_story }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def update
    if @posts_story.update(post_params)
      respond_to do |format|
        format.json { render json: @posts_story }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def destroy
    @posts_story.destroy

    respond_to do |format|
      format.json { render json: { id: @posts_story.id } }
    end
  end

private

  def posts_story_params
    params.require(:posts_story).permit(:story_id, :is_highlighted)
  end

  def set_posts_story
    @posts_story = PostsStory.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end
  
end
