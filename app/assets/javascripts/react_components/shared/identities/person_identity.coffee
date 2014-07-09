# Expose
#
tag = React.DOM


# Person identity component
#
MainComponent = React.createClass


  getDefaultProps: ->
    model: cc.models.Person.get(@props.key)
  
  
  onClick: (event) ->
    @props.onClick({ target: { value: @props.model }}) if @props.onClick instanceof Function
  
  
  render: ->
    (tag.li {
      className:  'person'
      onClick:    @onClick
    },
      (tag.aside {}, @props.model.letters())
      (tag.div { className: 'name' },
        @props.model.first_name
        " "
        (tag.strong {}, @props.model.last_name)
      )
      (tag.div { className: 'occupation' },
        @props.model.occupation
      )
    )


# Expose
#
@cc.react.shared.identities.Person = MainComponent
