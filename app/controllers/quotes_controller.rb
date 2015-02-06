class QuotesController < ApplicationController
  before_action :find_owner, only: [:create, :update]

  def show
    begin
      @quote = Quote.find(params[:id])

      respond_to do |format|
        format.json { render json: { quote: @quote } }
      end

    rescue ActiveRecord::RecordNotFound
      format.json { render json: :fail, status: 422 }
    end
  end

  def create
    @quote = @owner.build_quote(quote_params)

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
    if @owner.quote.update(quote_params)
      respond_to do |format|
        format.json { render json: { id: @owner.quote.uuid } }
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
    params.require(:quote).permit(:content, :person_id)
  end

end