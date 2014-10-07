# Imports
#
tag = React.DOM


BlockStore  = require('stores/block_store')
PersonStore = require('stores/person')


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


  gatherPeople: ->
    _.chain(@state.people)
      .sortBy(['last_name', 'first_name'])
      .reject (person) => _.contains(@state.block.identity_ids, person.uuid)
      .map (person) =>
        (tag.div {
          key:        person.uuid
          className:  'person'
          onClick:    @onPersonClick.bind(@, person.uuid)
        },
          (tag.i { className: 'fa fa-user' })
          person.full_name
        )
      .value()
  
  
  onPersonClick: (key, event) ->
    @props.onSelect(key) if _.isFunction(@props.onSelect)
  
  
  onNewPersonClick: (event) ->
    @props.onCreateClick() if _.isFunction(@props.onCreateClick)


  onQueryChange: (event) ->
    @setState({ query: event.target.value })
  
  
  getStateFromStores: ->
    block = BlockStore.get(@props.key)
    
    block:  block
    people: PersonStore.filter (person) -> person.company_id == block.owner_id


  getInitialState: ->
    state         = @getStateFromStores()
    state.query   = ''
    state


  render: ->
    (tag.div {
      className: 'vacancy-chooser'
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
        # New person
        #
        NewPersonComponent.apply(@)

        # People list
        #
        @gatherPeople()
      )
      
    )


# Exports
#
module.exports = Component
