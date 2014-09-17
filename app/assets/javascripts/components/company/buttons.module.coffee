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


# Exports
#
module.exports =
  InviteUserButton:   InviteUserButton
  CurrentUsersButton: CurrentUsersButton
  SendInviteButton:   SendInviteButton
