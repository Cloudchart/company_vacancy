# @cjsx React.DOM

# Imports
#
CloudFlux = require('cloud_flux')
GlobalState = require('global_state/state')

CompanyStore = require('stores/company')
RoleStore  = require('stores/role_store')
UserStore = require('stores/user_store')
TokenStore = require('stores/token_store')

CompanyActions  = require('actions/company')

CompanyInviteUserForm = require('components/company/access_rights/invite_user_form')
CompanyUsersList = require('components/company/access_rights/users_list')

Modes = 
  VIEW:   'view'
  INVITE: 'invite'

# Main
#
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions]

  propTypes:
    uuid: React.PropTypes.any.isRequired

  # Helpers
  # 
  createNewToken: ->
    TokenStore.create({ owner_id: @props.uuid, owner_type: 'Company' })

  getCloudFluxActions: ->
    'token:create:done': @handleTokenCreateDone
    'company:access_rights:fetch:done': @handleAccessRightsDone

  # Handlers
  # 
  handleTokenCreateDone: ->
    @setState({ mode: Modes.VIEW })

  handleAccessRightsDone: -> 
    @setState isAccessRightsLoaded: true

  onInviteUserButtonClick: (event) ->
    @setState
      mode: Modes.INVITE
      newTokenKey: @createNewToken()
  
  onCurrentUsersButtonClick: (event) ->
    TokenStore.remove(@state.newTokenKey)
    @setState({ mode: Modes.VIEW })

  # Lifecylce Methods
  # 
  componentWillMount: ->
    isAccessRightsLoaded = !!GlobalState.cursor(['flags', 'companies']).get('isAccessRightsLoaded')

    if isAccessRightsLoaded
      @setState isAccessRightsLoaded: isAccessRightsLoaded
    else
      CompanyActions.fetchAccessRights(@props.uuid)

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    RoleStore.on('change', @refreshStateFromStores)
    UserStore.on('change', @refreshStateFromStores)
    TokenStore.on("change", @refreshStateFromStores)
  
  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    RoleStore.off('change', @refreshStateFromStores)
    UserStore.off('change', @refreshStateFromStores)
    TokenStore.off("change", @refreshStateFromStores)

  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)

  getInitialState: ->
    state = @getStateFromStores()
    state.newTokenKey = null
    state.mode = Modes.VIEW
    state.isAccessRightsLoaded = false
    state.cursor = 
      constants: GlobalState.cursor(['constants', 'companies'])
    state

  render: ->
    return null unless @state.company && @state.isAccessRightsLoaded

    <div className="access-rights">
      {
        switch @state.mode
        
          when Modes.VIEW
            <CompanyUsersList
              uuid = {@props.uuid}
              cursor = {@state.cursor}
              onInviteUserButtonClick = {@onInviteUserButtonClick}
            />

          when Modes.INVITE
            <CompanyInviteUserForm
              uuid = {@props.uuid}
              cursor = {@state.cursor}
              tokenKey = {@state.newTokenKey}
              onCurrentUsersButtonClick = {@onCurrentUsersButtonClick}
            />
      }
    </div>

# Exports
#
module.exports = Component
