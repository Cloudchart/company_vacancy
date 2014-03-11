class FeaturesController < ApplicationController
  load_and_authorize_resource
  # before_action :set_feature, only: [:show, :edit, :update, :destroy, :vote]

  # GET /features
  def index
    # @features = Feature.all
  end

  # GET /features/1
  def show
  end

  # GET /features/new
  def new
    @feature = Feature.new
  end

  # GET /features/1/edit
  def edit
  end

  # POST /features
  def create
    @feature = Feature.new(feature_params)

    if @feature.save
      redirect_to @feature, notice: 'Feature was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /features/1
  def update
    if @feature.update(feature_params)
      redirect_to @feature, notice: 'Feature was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /features/1
  def destroy
    @feature.destroy
    redirect_to features_url, notice: 'Feature was successfully destroyed.'
  end

  def vote
    unless current_user.has_already_voted_for?(@feature)
      vote = @feature.votes.build(value: 1)
      vote.source = current_user
      vote.save
    end
    redirect_to :back
  end

private
  # Use callbacks to share common setup or constraints between actions.
  # def set_feature
  #   @feature = Feature.find(params[:id])
  # end

  # Only allow a trusted parameter "white list" through.
  def feature_params
    params.require(:feature).permit(:name, :description)
  end

end
