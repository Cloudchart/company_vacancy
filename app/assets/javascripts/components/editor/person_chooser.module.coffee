# @cjsx React.DOM

ModalStack    = require('components/modal_stack')

BlockStore    = require('stores/block_store')
PersonStore   = require('stores/person')
QuoteStore    = require('stores/quote_store')

PersonActions = require('actions/person_actions')
PersonAvatar  = require('components/shared/person_avatar')
PersonForm    = require('components/form/person_form')


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
    _.extend @getStateFromStores(),
      query: ''

  getStateFromStores: ->
    people: PersonStore.filter (person) => person.company_id == @props.company_id

  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  # Helpers
  #
  isPersonUsed: (person_id) ->
    !!(QuoteStore.findByPerson(person_id) ||
      BlockStore.find((block) -> block.identity_type == "Person" && block.identity_ids.indexOf(person_id) != -1))


  # Handlers
  #
  handlePersonClick: (key, event) ->
    @props.onSelect(key)

  handlePersonDelete: (uuid, event) ->
    event.preventDefault()
    event.stopPropagation()
    PersonActions.destroy(uuid)
  
  handleNewPersonClick: (event) ->
    return if @props.readOnly

    newPersonKey = PersonStore.create({ company_id: @props.company_id })

    ModalStack.show(<PersonForm
      attributes = { PersonStore.get(newPersonKey).toJSON() }
      onSubmit   = { -> ModalStack.hide() }
      uuid       = { newPersonKey } />,
    {
      beforeHide: =>
        PersonStore.remove(newPersonKey)
    })

  handleQueryChange: (event) ->
    @setState({ query: event.target.value })


  # Lifecycle methods
  #
  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)


  # Renderers:
  #
  renderPeople: ->
    queries = _.compact(@state.query.toLowerCase().split(/\s+/))
    
    people = _.chain(@state.people)
      .sortBy(['last_name', 'first_name'])
      .reject (person) => @props.selected.contains(person.uuid)
      .filter (person) -> _.all queries, (query) -> person.full_name.toLowerCase().indexOf(query) >= 0
      .reduce((memo, person) =>
        isPersonUsed = @isPersonUsed(person.uuid)

        component = <li
          key        = { person.uuid || 'new' }
          className  = { 'person' }
          onClick    = { @handlePersonClick.bind(@, person.uuid) }>
          <PersonAvatar
            avatarURL = { person.avatar_url }
            readOnly  = { true }
            value     = { person.full_name } />
          { person.full_name }
          { <i className="cc-icon cc-times" onClick={ @handlePersonDelete.bind(@, person.uuid) }></i> if !isPersonUsed }
        </li>

        memo[if isPersonUsed then 'used' else 'not_used'].push component

        memo
          
      , { used: [], not_used: [] })
      .value()

      <section>
        <ul className="used">
          <li className = 'new' onClick = { @handleNewPersonClick }>
            <i className='fa fa-plus'></i>
            New person
          </li>
          { people.used }
        </ul>
        <div className="separator">Not used</div>
        <ul className="not_used">{ people.not_used }</ul>
      </section>


  render: ->
    <div className='chooser'>
      <header>
        <input
          autoFocus   =  { true }
          value       =  { @state.query }
          onChange    =  { @handleQueryChange }
          placeholder = 'Type here...'
        />
      </header>
      
      { @renderPeople() }
    </div>


# Exports
#
module.exports = Component
