class PeopleController < ApplicationController
  before_action :set_company, only: [:index, :new, :create, :search]
  before_action :set_person, only: [:show, :edit, :update, :destroy, :make_owner, :invite_user]

  authorize_resource

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
    @person = @company.people.build
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    @person = @company.people.build(person_params)

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
    if @person.update(person_params)
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

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit([:first_name, :last_name, :full_name, :birthday, :email, :phone, :int_phone, :skype, :occupation, :hired_on, :fired_on, :salary, :stock_options, :bio])
  end

end
