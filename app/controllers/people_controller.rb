class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy, :make_owner, :invite_user]
  before_action :set_company, only: [:index, :new, :create, :search]
  before_action :build_person, only: :new
  before_action :build_person_with_params, only: :create
  before_action :authorize_company, only: :index

  authorize_resource except: :index

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
      redirect_to @person, notice: t('messages.created', name: t('lexicon.person'))
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /people/1
  def update
    if @person.update(person_params)
      redirect_to @person, notice: t('messages.updated', name: t('lexicon.person'))
    else
      render action: 'edit'
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

  def build_person
    @person = @company.people.build
  end

  def build_person_with_params
    @person = @company.people.build(person_params)
  end

  def authorize_company
    authorize! :access_people, @company
  end

end
