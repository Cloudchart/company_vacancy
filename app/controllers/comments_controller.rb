class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update, :destroy]

  authorize_resource

  # POST /comments
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.save!
    
    respond_to do |format|
      format.js
    end
  end

  # PATCH/PUT /comments/1
  # def update
  #   if @comment.update(comment_params)
  #     redirect_to @comment, notice: 'Comment was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  # DELETE /comments/1
  def destroy
    @comment.destroy

    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:content, :commentable_id, :commentable_type)
    end

end
