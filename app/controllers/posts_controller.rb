class PostsController < ApplicationController  

  # before_action :set_post
  before_action :set_company, only: [:index, :create]

  def index
    @posts = @company.posts.includes(blocks: :block_identities)

    respond_to do |format|
      format.json
    end
  end

  def create
  end

private

  def set_post
  end

  def set_company
    @company = Company.find(params[:company_id])
  end
  
end
