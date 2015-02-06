class QuotesController < ApplicationController
  before_action :find_owner, only: [:create, :update]

  def show
    @quote = Quote.find(params[:id])

    respond_to do |format|
      format.json { render json: { quote: @quote } }
    end
  end

  def create
    @quote = @owner.build_quote(quote_params)
    authorize!(params[:action], @quote)

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
    @quote = @owner.quote
    authorize!(params[:action], @quote)

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
  
  def find_owner
    @owner = begin
      case params[:type]
        when :block
          Block.where(identity_type: Quote.name).includes(:quote).find(params[:block_id])
      end
    end
  end
  
  def quote_params
    params.require(:quote).permit(:text, :person_id)
  end

end