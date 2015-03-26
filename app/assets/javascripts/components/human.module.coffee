# @cjsx React.DOM


GlobalState = require('global_state/state')


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
    uuid:           React.PropTypes.string.isRequired
    showOccupation: React.PropTypes.bool
    type:           React.PropTypes.string

  getDefaultProps: ->
    showOccupation: true


  fetch: ->
    GlobalState.fetch(@getQuery(@props.type), { id: @props.uuid })


  componentWillMount: ->
    @cursor = Stores[@props.type].cursor.items.cursor(@props.uuid)

    @fetch() unless @cursor.deref(false) if @props.uuid


  renderAvatar: ->
    <Avatar backgroundColor="transparent" avatarURL={ @cursor.get('avatar_url') } value={ @cursor.get('full_name') } />


  renderName: ->
    <p className="name">{ @cursor.get('full_name') }</p>


  renderOccupation: ->
    return null unless (occupation = @cursor.get('occupation', false)) && @props.showOccupation

    <p className="occupation">{ occupation }</p>


  renderCredentials: ->
    <section className="credentials">
      { @renderName() }
      { @renderOccupation() }
    </section>


  render: ->
    return null unless @cursor.deref(false)

    if @props.type == 'user'
      <a className="human for-group" href={ @cursor.get('user_url') }>
        { @renderAvatar() }
        { @renderCredentials() }
      </a>
    else
      <div className="human">
        { @renderAvatar() }
        { @renderCredentials() }
      </div>
