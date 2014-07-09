##= require models

# Expose
#
tag         = React.DOM
PersonModel = cc.models.Person

# Person component
#
MainComponent = React.createClass

  
  getInitialState: ->
    model: if @props.model instanceof PersonModel then @props.model else PersonModel.get(@props.model.uuid) || new PersonModel(@props.model)

  
  render: ->
    (tag.div { className: 'person' },
      (tag.p { className: 'name' },
        @props.model.first_name
        " "
        (tag.strong {}, @props.model.last_name)
      )
      (tag.p { className: 'occupation' }, @props.model.occupation)
    )


# Expose
#
cc.react.editor.blocks.Person = MainComponent
