class PostsStoriesController < ApplicationController  

  # before_action :set_post, only: [:update, :destroy]
  # before_action :set_company, only: [:index, :create]

  # authorize_resource

  # def create
  #   @post = @company.posts.build(post_params)

  #   if @post.save
  #     respond_to do |format|
  #       format.json { render json: @post }
  #     end
  #   else
  #     respond_to do |format|
  #       format.json { render json: :fail, status: 422 }
  #     end
  #   end
  # end

  # def update
  #   if @post.update(post_params)
  #     respond_to do |format|
  #       format.json { render json: @post }
  #     end
  #   else
  #     respond_to do |format|
  #       format.json { render json: :fail, status: 422 }
  #     end
  #   end
  # end

  def destroy
    posts_story = PostsStory.find_by!(post_id: params[:post_id], story_id: params[:story_id])
    posts_story.destroy

    respond_to do |format|
      format.json { render json: :ok }
    end
  end

private

  def posts_story_params
    params.require(:posts_story).permit(:is_highlighted)
  end

  # def set_post
  #   @post = Post.find(params[:id])
  # end

  # def set_company
  #   @company = find_company(Company.includes(:roles, :stories))
  # end

  # def find_company(relation)
  #   relation.find_by(slug: params[:company_id]) || relation.find(params[:company_id])
  # end
  
end
