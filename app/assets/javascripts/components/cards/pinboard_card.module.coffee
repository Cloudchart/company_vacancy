# @cjsx React.DOM


GlobalState     = require('global_state/state')

PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')

AuthButton      = require('components/form/buttons').AuthButton

SyncAPI         = require('sync/pinboard_sync_api')
RoleSyncAPI     = require('sync/role_sync_api')

cx              = React.addons.classSet
pluralize       = require('utils/pluralize')

module.exports = React.createClass


  propTypes:
    pinboard: React.PropTypes.string.isRequired


  getInitialState: ->
    pinboard: null
    sync:     null


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            user,
            edges {
              is_followed,
              readers_count,
              pins_count,
              invitation_id
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), id: @props.pinboard).done =>
      @addCursor('pinboard', PinboardStore.cursor.items.cursor(@props.pinboard))
      @addCursor('user', UserStore.cursor.items.cursor(@getCursor('pinboard').get('user_id')))
      @setState
        pinboard: @getCursor('pinboard')
        user:     @getCursor('user')


  fetchEdges: ->
    GlobalState.fetchEdges('Pinboard', @props.pinboard).done =>
      @setState
        sync: null


  # Events
  #

  handleFollowButtonClick: (event) ->
    return if @state.sync
    return if @state.pinboard.get('is_followed', false)
    @setState
      sync: 'follow_collection'

    SyncAPI.follow(@props.pinboard).done @fetchEdges


  handleAcceptInvitationButtonClick: (invitation_id, event) ->
    return if @state.sync
    @setState
      sync: 'accept_invitation'

    RoleSyncAPI.acceptInvitation(@state.pinboard.get('invitation_id')).then @fetchEdges


  handleDeclineInvitationButtonClick: (invitation_id, event) ->
    return if @state.sync
    @setState
      sync: 'decline_invitation'

    RoleSyncAPI.declineInvitation(@state.pinboard.get('invitation_id')).then @fetchEdges



  componentDidMount: ->
    @fetch()


  # Renders
  #

  renderFollowButton: ->
    className = cx
      'transparent':  @state.pinboard.get('is_followed')
      'sync':         @state.sync == 'follow_collection'

    iconClassName = cx
      'fa':         true
      'fa-check':   @state.pinboard.get('is_followed')
      'fa-plus':   !@state.pinboard.get('is_followed')

    label = if @state.pinboard.get('is_followed') then 'Following' else 'Follow'
    label += '...' if @state.sync == 'follow_collection'

    <AuthButton>
      <button className={ className } onClick={ @handleFollowButtonClick }>
        <span>{ label }</span>
        <i className={ iconClassName } />
      </button>
    </AuthButton>


  renderTitleAndFollowButton: ->
    <header>
      <h1>
        <a href={ @state.pinboard.get('url') } className="through">
          { @state.pinboard.get('title') }
        </a>
      </h1>
      { @renderFollowButton() }
    </header>


  renderDescription: ->
    return null unless description = @state.pinboard.get('description', null)
    <section className="description">
      <p>
        { description }
      </p>
    </section>


  renderOwnerOccupation: ->
    occupation = [@state.user.get('occupation'), @state.user.get('company')].filter((part) -> !!part).join(', ')
    return null unless occupation
    <p className="occupation">
      { occupation }
    </p>


  renderOwner: ->
    <figure className="user">
      <img src={ @state.user.get('avatar_url') } />
      <figcaption>
        <a href={ @state.user.get('url') } className="name">
          { @state.user.get('full_name') }
        </a>
        { @renderOwnerOccupation() }
      </figcaption>
    </figure>


  renderOwnerAndCounters: ->
    <section className="owner-and-counters">
      <ul>
        <li className="owner">
          { @renderOwner() }
        </li>
        <li className="counter followers">
          { pluralize @state.pinboard.get('readers_count'), 'follower', 'followers' }
        </li>
        <li className="counter insights">
          { pluralize @state.pinboard.get('pins_count'), 'insight', 'insights' }
        </li>
      </ul>
    </section>


  renderInvitationControls: ->
    return null unless invitation_id = @state.pinboard.get('invitation_id', false)

    accept_label    = 'Accept'
    accept_label   += '...' if @state.sync == 'accept_invitation'
    decline_label   = 'Decline'
    decline_label  += '...' if @state.sync == 'decline_invitation'

    <section className="invitation">
      <p>
        You've been invited to this collection
      </p>
      <AuthButton>
        <button onClick={ @handleAcceptInvitationButtonClick.bind(@, invitation_id) }>
          { accept_label }
        </button>
      </AuthButton>
      <AuthButton>
        <button className="alert" onClick={ @handleDeclineInvitationButtonClick.bind(@, invitation_id) }>
          { decline_label }
        </button>
      </AuthButton>
    </section>


  render: ->
    return null unless @state.pinboard

    className = cx @props.className, 'collection-card'

    <div className={ className }>
      { @renderTitleAndFollowButton() }
      { @renderDescription() }
      { @renderOwnerAndCounters() }
      { @renderInvitationControls() }
    </div>
