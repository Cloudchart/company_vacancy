# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore  = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')
PostStore = require('stores/post_store.cursor')


# Components
#
Human           = require('components/human')
PinnablePreview = require('components/pinnable/preview')
PinnablePost    = require('components/pinnable/post')
PinButton       = require('components/pinnable/pin_button')
InsightContent  = require('components/pinnable/insight_content')


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
    showPinButton: React.PropTypes.bool
    onClick:       React.PropTypes.func

  statics:

    queries:

      pin: ->
        """
          Pin {
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
    showPinButton: true

  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.uuid })

  isLoaded: ->
    @cursor.pin.deref(false)

  gatherPinAttributes: (insight) ->
    uuid:           insight.get('uuid')
    parent_id:      insight.get('parent_id')
    pinnable_id:    insight.get('pinnable_id')
    pinnable_type:  insight.get('pinnable_type')
    title:          insight.get('content')


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      pin:  PinStore.cursor.items.cursor(@props.uuid)
      user: UserStore.me()

    @fetch() unless @isLoaded()


  # Helpers
  #
  getInsight: ->
    if @cursor.pin.get('parent_id')
      PinStore.getParentFor(@props.uuid)
    else if @cursor.pin.get('content')
      @cursor.pin

  isClickable: ->
    _.isFunction(@props.onClick)


  # Handlers
  #
  handleClick: (event) ->
    return unless @isClickable()

    @props.onClick(@cursor.pin)


  # Renderers
  #
  renderInsightControls: (insight) ->
    return null unless @props.showPinButton

    <ul className="round-buttons">
      <PinButton {...@gatherPinAttributes(insight)} />
    </ul>

  renderPinContent: (content, className = 'paragraph') ->
    return null unless content

    <p className={ className } dangerouslySetInnerHTML={ __html: content } />

  renderInsight: ->
    return unless insight = @getInsight()

    <article className="insight">
      <InsightContent
        pinnable_id = { @cursor.pin.get('pinnable_id') }
        pin_id      = { insight.get('uuid') }  />

      <Human
        showUnicornIcon = { true }
        showLink        = { !@isClickable() }
        type            = "user"
        uuid            = { insight.get('user_id') } />

      { @renderInsightControls(insight) }
    </article>

  renderPinnablePreviewOrInsight: ->
    if insight = @getInsight()
      @renderInsight()
    else
      <PinnablePreview uuid={ @props.uuid } />

  renderComment: ->
    return null if ((insight = @getInsight()) && insight.get('uuid') == @props.uuid)

    <footer>
      { @renderPinContent(@cursor.pin.get('content')) }
      <i className="fa fa-share" />
      <Human type="user" uuid={ @cursor.pin.get('user_id') } />
    </footer>

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
