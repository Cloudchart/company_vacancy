person = cc.blueprint.models.Person.instances['<%= @person.to_param %>']
person.destroy()
cc.ui.modal.close()
cc.blueprint.dispatcher.sync()
