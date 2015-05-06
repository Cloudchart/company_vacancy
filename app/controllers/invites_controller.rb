class InvitesController < ApplicationController

  authorize_resource class: :invite

  def index
    # maybe list invites based on activities
  end

  def create
    # create user based on twitter response
    # create activity
  end

  def email
    # add validation
    # send email based on params
  end

end
