class InterviewDecorator < ApplicationDecorator
  decorates :interview

  def first_name
    interview.name.split.first
  end

  def whosaid
    ", #{interview.whosaid}" if interview.whosaid.present?
  end

end
