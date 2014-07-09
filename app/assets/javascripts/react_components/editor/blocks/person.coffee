##= require models

# Expose
#
tag         = React.DOM

PersonModel = cc.models.Person

PersonColors = [
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
]


# Person component
#
MainComponent = React.createClass

  
  getInitialState: ->
    model: if @props.model instanceof PersonModel then @props.model else PersonModel.get(@props.model.uuid) || new PersonModel(@props.model)
  
  
  onDelete: ->
    @props.onDelete({ target: { value: @props.model.uuid } }) if @props.onDelete instanceof Function

  
  onChange: ->
    @props.onChange({ target: { value: @props.model.uuid } }) if @props.onChange instanceof Function

  
  render: ->
    (tag.div {
      className: 'person'
      style:
        backgroundColor: PersonColors[@state.model.initials_hash() % PersonColors.length]
    },
      (tag.button { className: 'delete', onClick: @onDelete }, 'Delete')
      (tag.button { className: 'change', onClick: @onChange }, 'Change')
      
      (tag.p { className: 'name' },
        @state.model.first_name
        " "
        (tag.strong {}, @state.model.last_name)
      )
      (tag.p { className: 'occupation' }, @state.model.occupation)
    )


# Expose
#
cc.react.editor.blocks.Person = MainComponent
