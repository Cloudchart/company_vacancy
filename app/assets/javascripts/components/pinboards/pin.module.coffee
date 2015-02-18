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
              user
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
    return unless insight = PinStore.cursor.items.cursor(@cursor.pin.get('parent_id')).deref(false)

    <div className="insight">
      <section className="paragraph" dangerouslySetInnerHTML={ __html: insight.get('content') } />
      <Human type="user" uuid={ insight.get('user_id') } />
    </div>


  renderComment: ->
    return unless @cursor.pin.deref(false)

    <footer>
      <section className="paragraph" dangerouslySetInnerHTML={ __html: @cursor.pin.get('content') } />
      <i className="fa fa-share" />
      <Human type="user" uuid={@cursor.pin.get('user_id')} />
    </footer>


  render: ->
    return null unless @isLoaded()

    <section className="pin cloud-card">
      <header className="cloud bottom-line">
        Pinnable preview
      </header>
      { @renderInsight() }
      { @renderComment() }
    </section>
