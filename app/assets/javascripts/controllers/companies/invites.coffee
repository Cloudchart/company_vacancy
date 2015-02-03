# Company Invite
# 
@['companies/invites#show'] = (data) ->
  AvatarComponent = require('components/avatar')
  container = document.querySelector('[data-react-mount-point="avatar"]')

  React.renderComponent(AvatarComponent(
    value: data.author_full_name
    avatarURL: data.author_avatar_url
  ), container)
