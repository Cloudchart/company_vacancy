class SandboxController < ApplicationController

  def index
    # UserMailer.activities_digest(User.friendly.find('flo'), 8.hours.ago, Time.now.utc).deliver
  end

end
