class QuotesController < ApplicationController

  before_action :set_owner, only: [:create, :update]
  before_action :set_quote, only: [:create, :update]

  load_and_authorize_resource

  def show
    respond_to do |format|
      format.json { render json: { quote: @quote } }
    end
  end

  def create
    if @quote.save
      respond_to do |format|
        format.json { render json: { id: @quote.uuid } }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

  def update
    if @quote.update(quote_params)
      respond_to do |format|
        format.json { render json: { id: @quote.uuid } }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, status: 422 }
      end
    end
  end

private
  
  def set_owner
    @owner = case params[:type]
    when :block
      Block.where(identity_type: Quote.name).includes(:quote).find(params[:block_id])
    end
  end

  def set_quote
    @quote = case action_name
    when 'create'
      @owner.build_quote(quote_params)
    when 'update'
      @owner.quote
    end
  end
  
  def quote_params
    params.require(:quote).permit(:text, :person_id)
  end

end