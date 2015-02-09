# Imports
#
tag = React.DOM

ModalStack  = require('components/modal_stack')

PersonStore = require('stores/person')

PersonForm  = require('components/form/person_form')


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

  # Component specifications
  #
  propTypes:
    company_id:     React.PropTypes.string.isRequired
    onSelect:       React.PropTypes.func
    selected:       React.PropTypes.instanceOf(Immutable.Seq).isRequired

  getDefaultProps: ->
    onSelect:      ->

  getInitialState: ->
    state         = @getStateFromStores()
    state.query   = ''
    state

  getStateFromStores: ->
    people: PersonStore.filter (person) => person.company_id == @props.company_id

  refreshStateFromStores: ->
    @setState(@getStateFromStores())


  # Helpers
  #
  gatherPeople: ->
    queries = _.compact(@state.query.toLowerCase().split(/\s+/))
    
    _.chain(@state.people)
      .sortBy(['last_name', 'first_name'])
      .reject (person) => @props.selected.contains(person.uuid)
      .filter (person) -> _.all queries, (query) -> person.full_name.toLowerCase().indexOf(query) >= 0
      .map (person) =>
        (tag.div {
          key:        person.uuid || 'new'
          className:  'person'
          onClick:    @onPersonClick.bind(@, person.uuid)
        },
          (tag.i { className: 'fa fa-user' })
          person.full_name
        )
      .value()

  # Handlers
  #
  onPersonClick: (key, event) ->
    @props.onSelect(key)
  
  onNewPersonClick: (event) ->
    return if @props.readOnly

    newPersonKey = PersonStore.create({ company_id: @props.company_id })

    ModalStack.show(PersonForm({
      attributes: PersonStore.get(newPersonKey).toJSON()
      onSubmit:   -> ModalStack.hide()
      uuid:       newPersonKey
    }), {
      beforeHide: =>
        PersonStore.remove(newPersonKey)
    })

  onQueryChange: (event) ->
    @setState({ query: event.target.value })


  # Lifecycle methods
  #
  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)


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
