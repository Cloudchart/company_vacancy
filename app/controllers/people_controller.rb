class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy, :make_owner, :invite_user]
  before_action :set_company, only: [:index, :new, :create, :search]
  before_action :build_person, only: :new
  before_action :build_person_with_params, only: :create
  before_action :authorize_company, only: :index

  authorize_resource except: :index

  skip_before_action :require_authenticated_user!
  before_action :require_authenticated_user!, except: :index

  # GET /people
  def index
    @people = @company.people.includes(:user)

    pagescript_params(company_id: @company.id)
    
    respond_to do |format|
      format.html
      format.json { render json: @people, root: false }
    end
  end

  def search
    company_people = Person.search(params).results
    company_people_friends = Friend.search(params).results

    @people = company_people + company_people_friends

    respond_to do |format|
      format.js
    end
  end

  # GET /people/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @person, root: false }
    end
  end

  # GET /people/new
  def new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    if @person.save
      respond_to do |format|
        format.html { redirect_to @person, notice: t('messages.created', name: t('lexicon.person')) }
        format.json { render json: @person, root: false }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @person, root: false, status: 422 }
      end
    end
  end

  # PATCH/PUT /people/1
  def update
    if @person.update(params_for_update)
      respond_to do |format|
        format.html { redirect_to @person, notice: t('messages.updated', name: t('lexicon.person')) }
        format.json { render json: @person, root: false }
      end
    else
      set_person
      respond_to do |format|
        format.html { render action: 'edit' }
        format.json { render json: @person, root: false, status: 422 }
      end
    end
  end

  # DELETE /people/1
  def destroy
    company = @person.company
    @person.destroy
    redirect_to company_people_url(company), notice: t('messages.destroyed', name: t('lexicon.person'))
  end

  def make_owner
    @person.update(is_company_owner: true)

    respond_to do |format|
      format.json { render json: { owners: @person.company.owners } }
    end      
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  # Only allow a trusted parameter "white list" through.
  def person_params
    params.require(:person).permit(:first_name, :last_name, :email, :phone, :occupation)
  end
  
  
  def params_for_create
    params.require(:person).permit([:first_name, :last_name, :full_name, :birthday, :email, :phone, :int_phone, :skype, :occupation, :hired_on, :fired_on, :salary, :stock_options, :bio])
  end

  def params_for_update
    params.require(:person).permit([:first_name, :last_name, :full_name, :birthday, :email, :phone, :int_phone, :skype, :occupation, :hired_on, :fired_on, :salary, :stock_options, :bio])
  end
  

  def build_person
    @person = @company.people.build
  end

  def build_person_with_params
    @person = @company.people.build(params_for_create)
  end

  def authorize_company
    authorize! :access_people, @company
  end

end
