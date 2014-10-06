# Imports
#
tag = React.DOM


# New Person component
#
NewPersonComponent = ->
  (tag.div {
    className: 'new'
    onClick:    @onNewPersonClick
  },
    (tag.i { className: 'fa fa-plus' })
    'New person'
  )


# Main
#
Component = React.createClass


  onQueryChange: (event) ->
    @setState({ query: event.target.value })


  getInitialState: ->
    query: ''


  render: ->
    (tag.div {
      className: 'person-chooser'
    },
    
      # Query
      #
      (tag.header null,
        (tag.input {
          ref:          'query-input'
          autoFocus:    true
          value:        @state.query
          onChange:     @onQueryChange
          placeholder:  'Type here...'
        })
      )
      
      (tag.section null,
        NewPersonComponent.apply(@)
      )
    )


# Exports
#
module.exports = Component
