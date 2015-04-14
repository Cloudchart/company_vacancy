# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
RoleStore = require('stores/role_store.cursor')
PinStore = require('stores/pin_store')

PinSyncAPI = require('sync/pin_sync_api')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'ModeratePinButton'

  # mixins: [GlobalState.mixin, GlobalState.query.mixin]

  # statics:
  #   queries:
  #     system_roles: ->
  #       """
  #         Viewer {
  #           system_roles
  #         }
  #       """

  propTypes:
    uuid: React.PropTypes.string.isRequired


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  
  # Lifecycle Methods
  # 
  componentWillMount: ->
    @cursor = 
      user: UserStore.me()
      pin: PinStore.cursor.items.cursor(@props.uuid)

  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  isLoaded: ->
    RoleStore.cursor.items.deref(false) and @cursor.user.deref(false) and @cursor.pin.deref(false)


  # Handlers
  # 
  handleModerateClick: (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    PinSyncAPI.approve(@cursor.pin).then (json) => PinStore.fetchOne(json.id)


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    return null unless @isLoaded() and !@cursor.pin.get('is_approved') and UserStore.isEditor()

    <li onClick = { @handleModerateClick } >
      <i className="fa fa-check" />
    </li>


# Exports
# 
module.exports = MainComponent
