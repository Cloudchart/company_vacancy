person = cc.blueprint.models.Person.get('<%= @person.to_param %>')
person.set_attributes(<%= raw @person.to_json(only: [:first_name, :last_name, :occupation]) %>)
cc.ui.modal.close()
cc.blueprint.dispatcher.sync()
