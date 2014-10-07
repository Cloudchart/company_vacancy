# Imports
#
tag = React.DOM
cx = React.addons.classSet

extendClasses = (className, genericClass='cc') ->
  _.compact([className, genericClass]).join(' ')
 
# Invite User Button
#
InviteUserButton = React.createClass

  render: ->
    (tag.button {
      className: extendClasses(@props.className)
      onClick: @props.onClick
    },
      'Invite'
      (tag.i { className: 'fa fa-ticket' })
    )


# Current Users Button
#
CurrentUsersButton = React.createClass


  render: ->
    (tag.button {
      className: extendClasses(@props.className)
      onClick: @props.onClick
    },
      'Current Users'
      (tag.i { className: 'fa fa-users' })
    )


# Send Invite Button
#
SendInviteButton = React.createClass


  render: ->
    (tag.button {
      onClick: @props.onClick
    },
      'Send Invite'
      (tag.i { className: 'fa fa-send-o' })
    )


# Resend Company Invite Button
#
ResendCompanyInviteButton = (props, state, callback) ->
  (tag.button {
    className:  extendClasses(props.className, 'cc resend')
    disabled: !!state.sync
    onClick:    callback
  },
    "Resend"
    (tag.i { className: 'fa fa-send-o fa-fw' }) unless state.sync == 'update'
    (tag.i { className: 'fa fa-spin fa-spinner fa-fw'}) if state.sync == 'update'
  )


# Resend Company Invite Button
#
CancelCompanyInviteButton = (props, state, callback) ->
  (tag.button {
    className:  extendClasses(props.className, 'cc cancel')
    disabled: !!state.sync
    onClick:    callback
  },
    "Cancel"
    (tag.i { className: 'fa fa-times fa-fw' }) unless state.sync == 'delete'
    (tag.i { className: 'fa fa-spin fa-spinner fa-fw'}) if state.sync == 'delete'
  )


# Revoke Role Button
#
RevokeRoleButton = (props) ->
  (tag.button {
    className:  extendClasses(props.className, 'cc revoke')
    disabled:   props.disabled
    onClick:    props.onClick
  },
    props.title     or "Revoke" unless props.sync
    props.syncTitle or "Revoke" if props.sync

    (tag.i { className: 'fa fa-times fa-fw' }) unless props.sync
    (tag.i { className: 'fa fa-spin fa-spinner fa-fw' }) if props.sync
  )


# Sync Button
#
SyncButton = (props) ->
  (tag.button {
    type:       'button'
    className:  extendClasses(props.className, 'cc sync')
    disabled:   props.disabled
    onClick:    props.onClick
  },
  
    if props.sync
      [
        props.syncTitle || props.title || 'Sync'
        (tag.i { key: 'button', className: "fa fa-fw fa-spin fa-spinner" })
      ]
    else
      [
        props.title || 'Sync'
        (tag.i { key: 'button', className: "fa fa-fw #{props.icon || 'fa-times'}" })
      ]
  )


# Exports
#
module.exports =
  InviteUserButton:           InviteUserButton
  CurrentUsersButton:         CurrentUsersButton
  SendInviteButton:           SendInviteButton
  ResendCompanyInviteButton:  ResendCompanyInviteButton
  CancelCompanyInviteButton:  CancelCompanyInviteButton
  RevokeRoleButton:           RevokeRoleButton
  SyncButton:                 SyncButton