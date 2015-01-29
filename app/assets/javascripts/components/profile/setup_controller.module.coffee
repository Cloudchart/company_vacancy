# @cjsx React.DOM

GlobalState = require("global_state/state")

UserStore   = require("stores/user_store.cursor")

SetupForm   = require("components/profile/setup_form")

Errors =
  password:
    missing:  "Enter password, please"

getErrorMessages = (errorsLists) ->
  errors = _.mapValues errorsLists, (errors, attributeName) ->
    _.map errors, (errorName) ->
      Errors[attributeName][errorName] || errorName

  errors

validate = (attributes) ->
  errors =
    password:  []

  if (!attributes.password || attributes.password == '')
    errors.password.push 'missing'

  errors


SetupController = React.createClass

  # Component Specifications
  # 
  propTypes:
    currentUserId: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin]

  getInitialState: ->
    attributes: Immutable.Map()
    errors:     Immutable.Map()
    isSyncing:  false

  getDefaultProps: ->
    cursor: 
      users: UserStore.cursor.items


  # Helpers
  #
  getStateFromStores: ->
    currentUser: UserStore.getCurrentUser()
    

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  # Handlers
  #
  onGlobalStateChange: ->
    @setState @getStateFromStores()  

  handleInputChange: (name, value) ->
    @setState
      attributes: @state.attributes.set(name, value)
      errrors:    @state.errors.set(name, [])

  handleSubmit: ->
    UserStore.update(@state.attributes)


  # Lifecycle
  #
  componentDidMount: ->
    UserStore.fetchCurrentUser() if @props.currentUserId && !@state.currentUser


  render: ->
    <SetupForm 
      attributes = { @state.attributes }
      errors     = { @state.errors }
      isSyncing  = { @state.isSyncing }
      onChange   = { @handleInputChange }
      onSubmit   = { @handleSubmit } />


module.exports = SetupController