person = cc.blueprint.models.Person.instances['<%= @person.to_param %>']
person.update(<%= raw @person.to_json(only: [:first_name, :last_name, :occupation]) %>)
cc.ui.modal.close()
