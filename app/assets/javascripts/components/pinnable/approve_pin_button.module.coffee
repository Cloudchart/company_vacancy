# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
RoleStore = require('stores/role_store.cursor')
PinStore = require('stores/pin_store')

PinSyncAPI = require('sync/pin_sync_api')

SyncButton = require('components/form/buttons').SyncButton


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'ApprovePinButton'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      system_roles: ->
        """
          Viewer {
            system_roles
          }
        """

  propTypes:
    uuid: React.PropTypes.string.isRequired

  getInitialState: ->
    isSyncing: false
    loaders: Immutable.Map()

  
  # Lifecycle Methods
  # 
  componentWillMount: ->
    @cursor = 
      user: UserStore.me()
      pin: PinStore.cursor.items.cursor(@props.uuid)

    GlobalState.fetch(@getQuery('system_roles')).then =>  
      @setState loaders: @state.loaders.set('system_roles', true) if @isMounted()

  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  isLoaded: ->
    !!@state.loaders.get('system_roles') and @cursor.user.deref(false) and @cursor.pin.deref(false)


  # Handlers
  # 
  handleModerateClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    if confirm('Are you sure?')
      @setState isSyncing: true
      
      PinSyncAPI.approve(@cursor.pin).then (json) => 
        PinStore.fetchOne(json.id).then =>
          @setState isSyncing: false if @isMounted()


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    return null unless @isLoaded() and !@cursor.pin.get('is_approved') and UserStore.isEditor()

    <li>
      <SyncButton
        className = "transparent"
        onClick   = { @handleModerateClick }
        sync      = { @state.isSyncing }
        iconClass = "fa fa-check" />
    </li>


# Exports
# 
module.exports = MainComponent
