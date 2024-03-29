class PeopleController < ApplicationController
  before_action :set_company, only: [:index, :create]
  before_action :set_person, except: :index

  load_and_authorize_resource

  before_action :mark_for_verification, only: [:create, :update], if: -> { current_user.editor? }

  # GET companies/1/people
  def index
    @people = @company.people.includes(:user)

    respond_to do |format|
      format.json { render json: @people, root: false }
    end
  end

  # GET /people/1
  def show
    respond_to do |format|
      format.json { render json: @person, root: false }
    end
  end

  # POST companies/1//people
  def create
    if @person.save
      respond_to do |format|
        format.json { render json: @person, root: false }
      end
    else
      respond_to do |format|
        format.json { render json: @person, root: false, status: 422 }
      end
    end
  end

  # PATCH/PUT /people/1
  def update
    if @person.update(person_params)
      respond_to do |format|
        format.json { render json: @person, root: false }
      end
    else
      respond_to do |format|
        format.json { render json: @person, root: false, status: 422 }
      end
    end
  end

  # DELETE /people/1
  def destroy
    if @person.destroy
      respond_to do |format|
        format.json { render json: :ok, root: false }
      end
    else
      respond_to do |format|
        format.json { render json: :fail, root: false, status: 422 }
      end
    end
  end

private

  def set_company
    @company = Company.find(params[:company_id])
  end

  # only if default finder needs to be overridden
  def set_person
    @person = if action_name == 'create'
      @company.people.build(person_params)
    end
  end

  def mark_for_verification
    @person.should_be_verified!
  end

  def person_params
    params.require(:person).permit([
      :first_name,
      :last_name,
      :full_name,
      :twitter,
      :birthday,
      :email,
      :phone,
      :int_phone,
      :skype,
      :occupation,
      :hired_on,
      :fired_on,
      :salary,
      :stock_options,
      :bio,
      :avatar,
      :remove_avatar
    ])
  end

end
