# @cjsx React.DOM

# Imports
#
RolesUserList   = require('components/roles/user_list')
RolesInviteForm = require('components/roles/invite_form')

Modes = 
  VIEW:   'view'
  INVITE: 'invite'

ownerType  = 'Pinboard'
roleValues = ['editor', 'reader']

# Main
#
Component = React.createClass

  displayName: 'PinboardRoles'

  propTypes:
    uuid: React.PropTypes.any.isRequired

  getInitialState: ->
    mode: Modes.VIEW


  changeMode: (mode) ->
    @setState mode: mode


  render: ->
    <section className="roles-access">
      {
        switch @state.mode
        
          when Modes.VIEW
            <RolesUserList
              ownerId        = { @props.uuid }
              ownerType      = { ownerType }
              roleValues     = { roleValues }
              onInviteClick  = { @changeMode.bind(@, Modes.INVITE) } />

          when Modes.INVITE
            <RolesInviteForm
              ownerId     = { @props.uuid }
              ownerType   = { ownerType }
              roleValues  = { roleValues }
              onBackClick = { @changeMode.bind(@, Modes.VIEW) } />
      }
    </section>

# Exports
#
module.exports = Component
