# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore  = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')


# Components
#
Human = require('components/human')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'Pin'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pin: ->
        """
          Pin {
            user,
            parent {
              user,
              children
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.uuid })


  isLoaded: ->
    @cursor.pin.deref(false)


  componentWillMount: ->
    @cursor =
      pin:          PinStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


  renderInsight: ->
    return unless insight = PinStore.getParentFor(@props.uuid)

    <section className="insight">
      { @renderPinContent(insight.get('content'), 'quote') }

      <Human type="user" uuid={ insight.get('user_id') } />

      <ul className="counters">
        <li>
          { PinStore.getChildrenFor(insight.get('uuid')).count() }
          <i className="fa fa-thumb-tack" />
        </li>
      </ul>
    </section>


  renderPinContent: (content, className = 'paragraph') ->
    return null unless content

    <p className={ className } dangerouslySetInnerHTML={ __html: content } />


  renderComment: ->
    <footer>
      { @renderPinContent(@cursor.pin.get('content')) }

      <i className="fa fa-share" />

      <Human type="user" uuid={@cursor.pin.get('user_id')} />
    </footer>


  render: ->
    return null unless @isLoaded()

    <section className="pin cloud-card">
      { @renderInsight() }
      { @renderComment() }
    </section>
