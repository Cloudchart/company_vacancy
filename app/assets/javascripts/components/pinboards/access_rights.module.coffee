# @cjsx React.DOM

# Imports
#
RolesAccessList = require('components/roles/access_list')
RolesInviteForm = require('components/roles/invite_form')

Modes = 
  VIEW:   'view'
  INVITE: 'invite'

ownerType  = 'Pinboard'
roleValues = ['editor', 'contributor', 'reader']

# Main
#
Component = React.createClass

  displayName: 'PinboardRoles'
  propTypes:
    uuid: React.PropTypes.string.isRequired


  getInitialState: ->
    mode: Modes.VIEW

  changeMode: (mode) ->
    @setState mode: mode

  render: ->
    <section className="access-rights">
      {
        switch @state.mode
        
          when Modes.VIEW
            <RolesAccessList
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
