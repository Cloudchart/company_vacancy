class FavoritesController < ApplicationController

  def create
    favoritable = params[:favoritable_type].to_s.classify.constantize.find(params[:favoritable_id])

    unless current_user.favorites.map(&:favoritable_id).include?(params[:favoritable_id])
      @favorite = current_user.favorites.create(favoritable: favoritable)
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy

    respond_to do |format|
      format.js
    end
  end

end
