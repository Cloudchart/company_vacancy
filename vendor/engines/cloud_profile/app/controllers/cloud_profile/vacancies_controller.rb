require_dependency "cloud_profile/application_controller"

module CloudProfile
  class VacanciesController < ApplicationController
    before_action :require_authenticated_user!

    def index
      @vacancies = Vacancy.joins(:company).where(company_id: current_user.companies.map(&:id)).order(created_at: :desc)
    end  

  end
end
