vacancy = cc.blueprint.models.Vacancy.instances['<%= @vacancy.to_param %>']
vacancy.update(<%= raw @vacancy.to_json(only: [:name, :description]) %>)
cc.ui.modal.close()
