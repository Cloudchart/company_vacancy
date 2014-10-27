class InterviewsController < ApplicationController
  before_action :set_itreview, only: :show

  layout 'landing'

  def show
    @interview = decorate(@interview)
  end

private

  def set_itreview
    @interview = Interview.find(params[:id])
  end

end
