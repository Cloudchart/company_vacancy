class ReflectionsController < ApplicationController

  def add_vote
    render(json: { error: 401 }) and return if current_user.guest?
    reflection  = Pin.find(params[:id])
    if reflection.users_votes.where(source_id: current_user.id, source_type: User.name).count == 0
      reflection.users_votes.create(source: current_user)
    end
    render json: { id: reflection.id }
  end

  def remove_vote
    render(json: { error: 401 }) and return if current_user.guest?
    reflection  = Pin.find(params[:id])
    reflection.users_votes.where(source_id: current_user.id, source_type: User.name).each(&:destroy)
    render json: { id: reflection.id }
  end

end
