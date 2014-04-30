vacancy = cc.blueprint.models.Vacancy.instances['<%= @vacancy.to_param %>']
vacancy.destroy()
cc.ui.modal.close()
