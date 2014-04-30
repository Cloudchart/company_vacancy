new cc.blueprint.models.Vacancy(<%= raw @vacancy.to_json(only: [:uuid, :name, :description]) %>)
cc.ui.modal.close()
