vacancy = cc.blueprint.models.Vacancy.get('<%= @vacancy.to_param %>')
vacancy.update(<%= raw @vacancy.to_json(only: [:name, :description]) %>)
cc.blueprint.dispatcher.sync()
cc.ui.modal.close()
