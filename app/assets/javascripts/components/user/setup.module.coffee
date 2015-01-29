# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore   = require('stores/user_store.cursor')

Setup = React.createClass

  # Component Specifications
  # 
  displayName: 'Setup'

  propTypes:
    currentUserId: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin]

  getInitialState: ->
    @getStateFromStores()

  getDefaultProps: ->
    cursor: 
      users: UserStore.cursor.items


  # Helpers
  #
  getStateFromStores: ->
    currentUser:  @props.cursor.users.get(@props.currentUserId)

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  # Handlers
  #
  onGlobalStateChange: ->
    @setState @getStateFromStores()  


  # Lifecycle
  #
  componentDidMount: ->
    UserStore.fetchCurrentUser() if @props.currentUserId && !@state.currentUser


  render: ->
    <div></div>


module.exports = Setup