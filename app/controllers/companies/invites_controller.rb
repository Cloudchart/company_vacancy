module Companies
  class InvitesController < ApplicationController
    
    
    # List
    #
    def index
      company     = Company.find(params[:company_id])
      
      respond_to do |format|
        format.json { render json: { tokens: company.invite_tokens }, root: false }
      end
    end
    

    # Show
    #
    def show
      token = Token.find(params[:id])

      @company = token.owner
      @author = @company.owner

      pagescript_params(
        author_full_name: @author.full_name,
        author_avatar_url: @author.avatar.try(:url),
        token: TokenSerializer.new(token).as_json
      )
    end
    
    
    # Create
    #
    def create
      company     = Company.find(params[:company_id])
      token       = Token.new params.require(:token).permit(data: [ :email, :role ] ).merge(name: 'invite', owner: company)
      
      token.save!
      
      respond_to do |format|
        format.json { render json: token, root: :token }
      end
      
      UserMailer.company_invite(token.data[:email], token).deliver

    rescue ActiveRecord::RecordInvalid
      
      respond_to do |format|
        format.json { render json: token, root: :token, status: 412 }
      end
    end
    

    # Resend
    #
    def resend
      company   = Company.find(params[:company_id])
      token     = company.tokens.where(name: :invite).find(params[:id])
      
      UserMailer.company_invite(token.data[:email], token).deliver

      respond_to do |format|
        format.json { render json: token, root: :token }
      end
    end
    
    
    # Destroy
    #
    def destroy
      token       = Token.find(params[:id])
      token.destroy
      
      respond_to do |format|
        format.json { render json: token, root: :token }
      end
    end
  
  end
end
