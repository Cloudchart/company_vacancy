# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore  = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')
PostStore = require('stores/post_store.cursor')
PinboardStore = require('stores/pinboard_store')


# Components
#
Human = require('components/human')
PinnablePreview = require('components/pinnable/preview')
PinnablePost = require('components/pinnable/post')
PinButton = require('components/pinnable/pin_button')
EditPinButton = require('components/pinnable/edit_pin_button')
InsightContent = require('components/pinnable/insight_content')
ShareInsightButton = require('components/insight/share_button')
InsightOrigin = require('components/insight/origin')
InsightSuggestion = require('components/insight/suggestion')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'Pin'

  mixins: [GlobalState.query.mixin]

  propTypes:
    uuid:          React.PropTypes.string.isRequired
    onClick:       React.PropTypes.func
    showAuthor:    React.PropTypes.bool

  statics:

    queries:

      pin: ->
        """
          Pin {
            #{InsightOrigin.getQuery('pin')},
            #{ShareInsightButton.getQuery('pin')},
            pinboard,
            post {
              #{PinnablePost.getQuery('post')}
            },
            user {
              unicorn_role
            },
            children,
            parent {
              pinboard,
              user {
                unicorn_role
              },
              children
            }
          }
        """

  getDefaultProps: ->
    showAuthor:  true

  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.uuid })

  isLoaded: ->
    @cursor.pin.deref(false)

  gatherPinAttributes: (insight) ->
    uuid:           insight.get('uuid')
    parent_id:      insight.get('parent_id')
    pinnable_id:    @cursor.pin.get('pinnable_id')
    pinnable_type:  @cursor.pin.get('pinnable_type')
    title:          insight.get('content')


  # Lifecycle methods
  #
  componentWillMount: ->
    pin = PinStore.cursor.items.cursor(@props.uuid)

    @cursor =
      pin: pin
      pinboard: PinboardStore.cursor.items.get(pin.get('pinboard_id'))
      user: UserStore.me()

    @fetch() unless @isLoaded()


  # Helpers
  #
  getInsight: ->
    if @cursor.pin.get('parent_id')
      PinStore.cursor.items.cursor(@cursor.pin.get('parent_id'))
    else if @cursor.pin.get('content')
      @cursor.pin

  isClickable: ->
    _.isFunction(@props.onClick)


  # Handlers
  #
  handleClick: (event) ->
    return unless @isClickable()
    @props.onClick(@cursor.pin.get('uuid'), event)

  handleDeleteSuggestionClick: (event) ->
    PinStore.destroy(@props.uuid) if confirm('Are you sure?')

  handleApproveSuggestionClick: (event) ->
    PinStore.approve(@props.uuid) if confirm('Are you sure?')


  # Renderers
  #
  renderEditButton: ->
    return null unless @getInsight()

    <EditPinButton uuid={ @getInsight().get('uuid') } />


  renderShareButton: ->
    return null unless @cursor.pin.deref(false)

    <ShareInsightButton pin = { @cursor.pin.deref().toJS() } />

  renderPinButton: ->
    return null unless insight = @getInsight()

    <PinButton {...@gatherPinAttributes(insight)} />

  renderInsightControls: (insight) ->
    <ul className="round-buttons">
      { @renderEditButton() }
      { @renderShareButton() }
      { @renderPinButton() }
    </ul>

  renderInsight: ->
    return unless insight = @getInsight()

    <article className="insight">
      <InsightContent
        pinnable_id = { @cursor.pin.get('pinnable_id') }
        pin_id = { insight.get('uuid') }
      />

      <footer>
        <Human
          showUnicornIcon = { true }
          showLink = { !@isClickable() }
          type = "user"
          uuid = { insight.get('user_id') }
        />

        { @renderInsightControls(insight) }
      </footer>
    </article>

  renderPinnablePreviewOrInsight: ->
    if insight = @getInsight()
      @renderInsight()
    else
      <PinnablePreview uuid={ @props.uuid } />

  renderCommentContent: ->
    return null unless content = @cursor.pin.get('content')

    if @cursor.pin.get('is_suggestion')
      <span>Suggested by</span>
    else
      <span dangerouslySetInnerHTML={ __html: content } />

  renderCommentAuthor: ->
    return null unless @props.showAuthor

    <Human
      isOneLiner = { true }
      type       = "user"
      uuid       = { @cursor.pin.get('user_id') } />

  renderComment: ->
    return null if @props.skipRenderComment
    return null if ((insight = @getInsight()) && insight.get('uuid') == @props.uuid) ||
      (!@cursor.pin.get('content') && !@props.showAuthor)

    <footer>
      <i className="fa fa-share" />
      <p>
        { @renderCommentContent() }
        { @renderSeparator() }
        { @renderCommentAuthor() }
      </p>
      { @renderSuggestionControls() }
    </footer>

  renderSeparator: ->
    if @cursor.pin.get('is_suggestion')
      <span> </span>
    else if @cursor.pin.get('content') && @props.showAuthor
      <span> – </span>

  renderSuggestionControls: ->
    return null unless @cursor.pin.get('is_suggestion')

    if @cursor.pinboard.get('is_editable')
      approve_element = if @cursor.pin.get('is_approved')
        null
      else
        <li>
          <i className="fa fa-check" onClick = { @handleApproveSuggestionClick } />
        </li>

      <ul className="suggestion-controls" >
        { approve_element }

        <li>
          <i className="cc-icon cc-times" onClick={ @handleDeleteSuggestionClick } />
        </li>
      </ul>
    else if @cursor.pin.get('user_id') == @cursor.user.get('uuid') && !@cursor.pin.get('is_approved')
      <span>Awaiting moderation</span>
    else
      null


  # Main render
  #
  render: ->
    return null unless @cursor.pin.deref(false) && @cursor.user.deref(false)

    classes = cx(
      pin:        true
      "cloud-card": true
      clickable:  @isClickable()
    )

    <section className={ classes } onClick={ @handleClick }>
      { @renderPinnablePreviewOrInsight() }
      { @renderComment() }
    </section>
