class BlocksController < ApplicationController
  def sort
    block = Block.find(params[:block_id])
    if params[:shift] == 'higher'
    elsif params[:shift] == 'lower'
    end
    redirect_to :back
  end
end
