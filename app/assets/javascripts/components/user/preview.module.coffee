# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore   = require('stores/user_store.cursor')

Avatar      = require('components/avatar')

cx          = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'UserPreview'

  mixins: [GlobalState.mixin]

  statics:
    getCursor: (id) ->
      user:      UserStore.cursor.items.cursor(id)

  render: ->
    return null unless @props.cursor.user.deref()

    user = @props.cursor.user

    <article 
      className    = "user-preview"
      onMouserOver = @handleMouseOver
      onMouseLeave = @handleMouseLeave >
      <Avatar
        avatarURL  = { user.get('avatar_url') }
        value      = { user.get('full_name') } />
      <section className='info'>
        <a href={ user.get('user_url') } className="for-group">
          <header>{ user.get('full_name') }</header>
        </a>
      </section>
    </article>
