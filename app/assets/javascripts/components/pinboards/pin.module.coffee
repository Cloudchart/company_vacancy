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
PinnableHeader  = require('components/pinnable/header')
PinnablePreview = require('components/pinnable/preview')
PinnablePost    = require('components/pinnable/post')
PinButton       = require('components/pinnable/pin_button')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'Pin'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    uuid: React.PropTypes.string.isRequired

  statics:

    queries:

      pin: ->
        """
          Pin {
            post {
              #{PinnablePost.getQuery('post')}
            },
            user,
            parent {
              user,
              children
            }
          }
        """

  componentWillMount: ->
    @cursor = 
      pin:  PinStore.cursor.items.cursor(@props.uuid)
      user: UserStore.me()

  # Renderers
  #
  renderControls: ->
    return null unless @cursor.pin.get('user_id') == @cursor.user.get('uuid')

    <ul className="round-buttons">
      <PinButton uuid = { @props.uuid } />
    </ul>

  renderPinContent: (content, className = 'paragraph') ->
    return null unless content

    <p className={ className } dangerouslySetInnerHTML={ __html: content } />

  renderInsight: ->
    return unless insight = PinStore.getParentFor(@props.uuid)

    <article className="insight">
      { @renderPinContent(insight.get('content'), 'quote') }

      <Human type="user" uuid={ insight.get('user_id') } />

      <ul className="counters">
        <li>
          { PinStore.getChildrenFor(insight.get('uuid')).count() }
          <i className="fa fa-thumb-tack" />
        </li>
      </ul>
    </article>

  renderComment: ->
    <footer>
      { @renderPinContent(@cursor.pin.get('content')) }
      <i className="fa fa-share" />
      <Human type="user" uuid={ @cursor.pin.get('user_id') } />
    </footer>

  render: ->
    return null unless @cursor.pin.deref(false) && @cursor.user.deref(false)

    <section className="pin cloud-card">
      <PinnableHeader uuid={ @props.uuid } />
      <PinnablePreview uuid={ @props.uuid } />
      { @renderControls() }
      { @renderInsight() }
      { @renderComment() }
    </section>
