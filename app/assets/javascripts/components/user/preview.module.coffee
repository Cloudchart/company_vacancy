# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore   = require('stores/user_store.cursor')
Avatar      = require('components/avatar')
Tooltip     = require('components/shared/tooltip')

cx          = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'UserPreview'

  mixins: [GlobalState.mixin]

  statics:
    getCursor: (id) ->
      user:      UserStore.cursor.items.cursor(id)


  # Renderers
  #
  renderInfo: ->
    user = @props.cursor.user

    <header>{ user.get('full_name') }</header>

  renderAvatar: ->
    user = @props.cursor.user

    <Avatar
      avatarURL  = { user.get('avatar_url') }
      value      = { user.get('full_name') } />


  render: ->
    return null unless @props.cursor.user.deref()

    <a href={ @props.cursor.user.get('user_url') } className="for-group">
      <Tooltip 
        element        = { @renderAvatar() }
        tooltipContent = { @renderInfo() } />
    </a>
