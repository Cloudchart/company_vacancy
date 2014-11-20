# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PersonStore = require('stores/person')

PersonActions = require('actions/person_actions')
ModalActions = require('actions/modal_actions')

PersonAvatar = require('components/shared/person_avatar')
PersonForm = require('components/form/person_form')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  # gatherSomething: ->

  # Handlers
  # 
  handleAvatarClick: (event) ->
    return if @props.readOnly

    ModalActions.show(PersonForm({
      attributes: @state.person.toJSON()
      onSubmit:   @handlePersonFormSubmit.bind(@, @state.person.uuid)
    }))

  handlePersonFormSubmit: (id, attributes) ->
    PersonActions.update(id, attributes.toJSON())

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->

  getStateFromStores: ->
    person: PersonStore.get(@props.id)

  getInitialState: ->
    @getStateFromStores()

  render: ->
    <article className="preview person">
      <PersonAvatar 
        value={@state.person.full_name}
        avatarURL={@state.person.avatar_url}
        onClick={@handleAvatarClick}
        readOnly={true}
      />
      <aside className="event"></aside>
      <footer>
        <p className="name">{@state.person.full_name}</p>
        <p className="occupation">{@state.person.occupation}</p>
      </footer>
    </article>

# Exports
# 
module.exports = Component
