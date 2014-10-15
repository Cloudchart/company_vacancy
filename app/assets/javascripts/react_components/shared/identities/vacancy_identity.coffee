# Expose
#
tag = React.DOM

Model = cc.models.Vacancy

# Person identity component
#
MainComponent = React.createClass


  getInitialState: ->
    model: Model.get(@props.key)
  
  
  onClick: (event) ->
    @props.onClick({ target: { value: @state.model.uuid }}) if @props.onClick instanceof Function
  
  
  render: ->
    (tag.li {
      className:  'vacancy'
      onClick:    @onClick
    },
      (tag.aside {},
        (tag.i { className: 'fa fa-briefcase' })
      )
      (tag.div { className: 'title' },
        @state.model.name
      )
      (tag.div { className: 'note' },
        @state.model.description
      )
    )


# Expose
#
@cc.react.shared.identities.Vacancy = MainComponent
