module BlockableController
  extend ActiveSupport::Concern

  included do
    before_action :set_blockable, only: [:update, :destroy]
  end

  def new
    instance_variable_set("@#{controller_name.singularize}", controller_name.classify.constantize.new)
    blockable.build_block.owner = Company.find(params[:company_id])
  end

  def create
    instance_variable_set("@#{controller_name.singularize}", controller_name.classify.constantize.new(send("#{controller_name.singularize}_params")))

    if blockable.save
      redirect_to edit_company_path(blockable.company), notice: t('messages.created', name: t("lexicon.#{controller_name.singularize}_block"))
    else
      redirect_to :back, alert: 'Validation errors'
    end
  end

  def update
    if blockable.update(send("#{controller_name.singularize}_params"))
      redirect_to edit_company_path(blockable.company), notice: t('messages.updated', name: t("lexicon.#{controller_name.singularize}_block"))
    else
      redirect_to :back, alert: 'Validation errors'
    end    
  end

  def destroy
    instance_variable_get("@#{controller_name.singularize}").destroy
    redirect_to :back, notice: t('messages.destroyed', name: t("lexicon.#{controller_name.singularize}_block"))
  end

  private

    def set_blockable
      instance_variable_set("@#{controller_name.singularize}", controller_name.classify.constantize.find(params[:id]))
    end

    def blockable_params(blockable_attributes)
      params.require(controller_name.singularize.to_sym).permit(blockable_attributes, block_attributes: [:section, :position, :owner_id, :owner_type])
    end

    def blockable
      instance_variable_get("@#{controller_name.singularize}")
    end

end
