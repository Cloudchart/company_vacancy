# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PersonStore = require('stores/person')

PersonAvatar = require('components/shared/person_avatar')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  # gatherSomething: ->

  # Handlers
  # 
  handleAvatarClick: (event) ->
    console.log 'handleAvatarClick'

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
    <article className="person preview">
      <div className="person avatar">
        <PersonAvatar 
          value={@state.person.full_name}
          avatarURL={@state.person.avatar_url}
          onClick={@handleAvatarClick}
          readOnly={true}
        />
        <footer>
          <p className="name">{@state.person.full_name}</p>
          <p className="occupation">{@state.person.occupation}</p>
        </footer>
      </div>
      <aside className="event"></aside>
    </article>

# Exports
# 
module.exports = Component
