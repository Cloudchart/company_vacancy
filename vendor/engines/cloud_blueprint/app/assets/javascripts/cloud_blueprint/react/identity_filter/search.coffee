#
#
#

# Shortcuts
#
tag = React.DOM


# Input
#
Input = (value, callback) ->
  (tag.input {
    key:          'search'
    type:         'search'
    value:        value
    onChange:     callback
    placeholder:  'People and Vacancies'
  })


#
#
#

Search = React.createClass

  displayName: 'IdentityFilterSearch'
  

  getInitialState: ->
    value: ''


  componentDidUpdate: ->
    @props.callback(@state.value)


  onChange: (event) ->
    @setState { value: event.target.value }


  render: ->
    (tag.section { className: 'search' },
      (tag.i { className: 'fa fa-search' })
      (Input @state.value, @onChange)
    )

#
#
#

_.extend @cc.blueprint.react.IdentityFilter,
  Search: Search
