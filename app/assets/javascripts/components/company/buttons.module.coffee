# Imports
#
tag = React.DOM


# Invite User Button
#
InviteUserButton = React.createClass


  render: ->
    (tag.button {
      onClick: @props.onClick
    },
      'Invite User'
      (tag.i { className: 'fa fa-send-o' })
    )


# Current Users Button
#
CurrentUsersButton = React.createClass


  render: ->
    (tag.button {
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
    className:  'resend'
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
    className:  'cancel'
    disabled: !!state.sync
    onClick:    callback
  },
    "Cancel"
    (tag.i { className: 'fa fa-times fa-fw' }) unless state.sync == 'delete'
    (tag.i { className: 'fa fa-spin fa-spinner fa-fw'}) if state.sync == 'delete'
  )


# Exports
#
module.exports =
  InviteUserButton:           InviteUserButton
  CurrentUsersButton:         CurrentUsersButton
  SendInviteButton:           SendInviteButton
  ResendCompanyInviteButton:  ResendCompanyInviteButton
  CancelCompanyInviteButton:  CancelCompanyInviteButton
