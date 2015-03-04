class UsersController < ApplicationController
  include FollowableController
  
  def show
    respond_to do |format|
      format.html
    end
  end
end
