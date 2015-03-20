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
    @cursor = PinStore.cursor.items.cursor(@props.uuid)

  # Renderers
  #
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
      { @renderPinContent(@cursor.get('content')) }
      <i className="fa fa-share" />
      <Human type="user" uuid={ @cursor.get('user_id') } />
    </footer>

  render: ->
    return null unless @cursor.deref(false)

    <section className="pin cloud-card">
      <PinnableHeader uuid={ @props.uuid } />
      <PinnablePreview uuid={ @props.uuid } />
      { @renderInsight() }
      { @renderComment() }
    </section>
