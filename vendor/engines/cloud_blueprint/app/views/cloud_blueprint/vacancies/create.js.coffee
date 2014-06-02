new cc.blueprint.models.Vacancy(<%= raw @vacancy.to_json(only: [:uuid, :name, :description]) %>)
cc.blueprint.dispatcher.sync()
cc.ui.modal.close()
