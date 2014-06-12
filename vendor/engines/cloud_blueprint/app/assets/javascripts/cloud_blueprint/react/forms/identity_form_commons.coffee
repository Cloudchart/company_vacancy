#
#
#

IdentityFormCommons =
  getInitialState: ->
    @props.model.attributes
  
  
  missingField: ->
    _.find(@getDOMNode().querySelectorAll('[required]'), (field) -> !field.value)
  
  onSubmit: (event) ->
    event.preventDefault()
    

    return missing_field.focus() and false if missing_field = @missingField()

    
    if @props.model.is_persisted()
      @props.model.update(@state).save()
      Arbiter.publish("#{@props.model.constructor.broadcast_topic()}/update")
    else
      @props.model.constructor.create(@state).save()
      Arbiter.publish("#{@props.model.constructor.broadcast_topic()}/create")
      
    cc.ui.modal.close()
  
  
  onDelete: (event) ->
    event.preventDefault()

    @props.model.destroy().save()
    Arbiter.publish("#{@props.model.constructor.broadcast_topic()}/delete")

    cc.ui.modal.close()


#
#
#

_.extend @cc.blueprint.react.forms,
  IdentityFormCommons: IdentityFormCommons