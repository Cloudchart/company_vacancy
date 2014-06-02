vacancy = cc.blueprint.models.Vacancy.get('<%= @vacancy.to_param %>')
vacancy.destroy()
cc.blueprint.dispatcher.sync()
cc.ui.modal.close()
