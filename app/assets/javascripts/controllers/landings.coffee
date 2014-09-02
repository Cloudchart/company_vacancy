cc.module('react/shared/letter-avatar')

# Company Invite
# 
@['landings#company_invite'] = (data) ->
  AvatarComponent = cc.require('cc.components.Avatar')
  container = document.querySelector('[data-react-mount-point="avatar"]')

  React.renderComponent(AvatarComponent(
    value: data.author_full_name
    avatarURL: data.author_avatar_url
  ), container)
