# Expose
#
tag = React.DOM

PersonModel = cc.models.Person

PersonColors = [
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
]


# Person identity component
#
MainComponent = React.createClass


  getDefaultProps: ->
    model: PersonModel.get(@props.key)
  
  
  onClick: (event) ->
    @props.onClick({ target: { value: @props.model.uuid }}) if @props.onClick instanceof Function
  
  
  render: ->
    (tag.li {
      className:  'person'
      onClick:    @onClick
    },
      (tag.aside {
        style:
          backgroundColor: PersonColors[@props.model.initials_hash() % PersonColors.length]
      }, @props.model.initials())
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
