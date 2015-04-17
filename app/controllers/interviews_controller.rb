class InterviewsController < ApplicationController
  before_action :set_itreview

  layout 'guest'

  def show
    @interview = decorate(@interview)
  end

  def accept
    unless @interview.is_accepted?
      @interview.update(is_accepted: true)
      UserMailer.interview_acceptance(@interview).deliver
    end
  end

private

  def set_itreview
    @interview = Interview.find(params[:id])
  end

end
