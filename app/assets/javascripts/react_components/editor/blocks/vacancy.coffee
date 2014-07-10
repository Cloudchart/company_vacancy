##= require models

# Expose
#
tag         = React.DOM

Model       = cc.models.Vacancy


# Vacancy Component
#
MainComponent = React.createClass

  
  getInitialState: ->
    model: if @props.model instanceof Model then @props.model else Model.get(@props.model.uuid) || new Model(@props.model)


  onDelete: ->
    @props.onDelete({ target: { value: @props.model.uuid } }) if @props.onDelete instanceof Function

  
  onChange: ->
    @props.onChange({ target: { value: @props.model.uuid } }) if @props.onChange instanceof Function

  
  render: ->
    (tag.div {
      className: 'vacancy'
    },
      (tag.div { className: 'flag' })

      (tag.button { className: 'delete', onClick: @onDelete }, 'Delete')
      (tag.button { className: 'change', onClick: @onChange }, 'Change')

      (tag.p { className: 'title' },
        (tag.strong {}, "Vacancy")
      )
      (tag.p { className: 'note' }, @state.model.name)
    )


# Expose
#
cc.react.editor.blocks.Vacancy = MainComponent
