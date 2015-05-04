class PeopleController < ApplicationController
  before_action :set_company, only: [:index, :create]
  before_action :set_person, except: :index

  load_and_authorize_resource

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

      verify_person!

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

      verify_person!

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


  def verify_person!
    return unless current_user.editor?
    user = User.find_by(twitter: @person.twitter)
    @person.update(user: user, is_verified: true) if user.present?
    user.roles.create!(value: :public_reader, owner: @company) if user.present? && !user.companies.include?(@company)
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
