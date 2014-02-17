class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :set_company, only: [:index, :new, :create]

  # GET /people
  def index
    @people = Person.all
  end

  # GET /people/1
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    @person = Person.new(person_params)
    @person.company = @company

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
      params.require(:person).permit(:name, :email, :phone, :occupation)
    end
end
