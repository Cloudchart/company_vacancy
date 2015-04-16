# @cjsx React.DOM


GlobalState = require('global_state/state')

RoleStore   = require('stores/role_store.cursor')


# Stores
#
Stores =
  'user':     require('stores/user_store.cursor')
  'person':   require('stores/person_store.cursor')


# Components
#
Avatar = require('components/avatar')


# Exports
#
module.exports = React.createClass


  displayName: 'Human'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:
      user: ->
        """
          User {}
        """

      person: ->
        """
          Person {}
        """

  propTypes:
    uuid:            React.PropTypes.string.isRequired
    showOccupation:  React.PropTypes.bool
    showLink:        React.PropTypes.bool
    showUnicornIcon: React.PropTypes.bool
    type:            React.PropTypes.string

  getDefaultProps: ->
    cursor:
      currentUser:     Stores.user.me()
      roles:           RoleStore.cursor.items
      showUnicornIcon: false
    showOccupation:    true
    showLink:          true

  fetch: ->
    GlobalState.fetch(@getQuery(@props.type), { id: @props.uuid })


  # Helpers
  #
  getLink: ->
    return null unless @props.showLink && @props.cursor.currentUser.get('twitter')

    if @props.type == 'user' 
      @cursor.get('user_url')
    else if @props.type == "person" && @cursor.get('is_verified')
      "/users/#{@cursor.get('twitter')}"

  isUnicorn: ->
    @props.cursor.roles.filter (role) =>
      role.get('owner_type', null)  is null       and
      role.get('owner_id',   null)  is null       and
      role.get('value')             is 'unicorn'  and
      role.get('user_id')           is @props.uuid
    .size

  updateCursor: (props) ->
    @cursor = Stores[props.type].cursor.items.cursor(props.uuid)

    @fetch() unless @cursor.deref(false) if props.uuid


  # Lifecycle methods
  #
  componentWillMount: ->
    @updateCursor(@props)

  componentWillReceiveProps: (newProps) ->
    if !@props.uuid != newProps.uuid
      @updateCursor(newProps)   

  # Renderers
  #
  renderAvatar: ->
    <Avatar backgroundColor="transparent" avatarURL={ @cursor.get('avatar_url') } value={ @cursor.get('full_name') } />

  renderTextWithIcon: (text, icon) ->
    if text && icon
      textParts = text.trim().split(' ')

      <span>
        { textParts[0..-2].join(' ') + " " }
        <span className="last-part">
          { textParts.pop() }
          { icon }
        </span>
      </span>
    else
      text

  renderUnicornIcon: ->
    return null unless @props.type == 'user' && @props.showUnicornIcon && @isUnicorn()

    <i className="svg-icon svg-unicorn" />

  renderName: ->
    <p className="name">
      { @renderTextWithIcon(@cursor.get('full_name'), @renderUnicornIcon()) }
    </p>

  renderOccupation: ->
    return null unless @props.showOccupation

    strings = []
    strings.push occupation if (occupation = @cursor.get('occupation'))
    strings.push company if (company = @cursor.get('company'))

    return null unless strings.length > 0

    <p className="occupation">{ strings.join(', ') }</p>

  renderCredentials: ->
    <section className="credentials">
      { @renderName() }
      { @renderOccupation() }
    </section>


  render: ->
    return null unless @cursor.deref(false) && @props.cursor.currentUser.deref(false)

    if (link = @getLink())
      <a className="human for-group" href={ link }>
        { @renderAvatar() }
        { @renderCredentials() }
      </a>
    else
      <div className="human">
        { @renderAvatar() }
        { @renderCredentials() }
      </div>
