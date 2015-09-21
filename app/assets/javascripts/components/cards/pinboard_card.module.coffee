# @cjsx React.DOM


GlobalState     = require('global_state/state')

PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')

cx              = React.addons.classSet
pluralize       = require('utils/pluralize')

module.exports = React.createClass


  propTypes:
    pinboard: React.PropTypes.string.isRequired


  getInitialState: ->
    pinboard: null


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
              is_invited
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


  # Events
  #

  handleFollowButtonClick: (event) ->
    return if @state.pinboard.get('is_followed', false)


  handleAcceptInvitationButtonClick: (event) ->


  handleDeclineInvitationButtonClick: (event) ->


  componentDidMount: ->
    @fetch()


  # Renders
  #

  renderFollowButton: ->
    className = cx
      'transparent': @state.pinboard.get('is_followed')

    label = if @state.pinboard.get('is_followed') then 'Following' else 'Follow'

    <button className={ className } onClick={ @handleFollowButtonClick }>{ label }</button>


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
    return null unless @state.pinboard.get('is_invited', false)

    <section className="invitation">
      <p>
        You've been invited to this collection
      </p>
      <button onClick={ @handleAcceptInvitationButtonClick }>
        Accept
      </button>
      <button className="alert" onClick={ @handleDeclineInvitationButtonClick }>
        Decline
      </button>
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
