new cc.blueprint.models.Person(<%= raw @person.to_json(only: [:uuid, :first_name, :last_name, :occupation]) %>)
cc.ui.modal.close()
