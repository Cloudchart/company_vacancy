# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore  = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')


# Components
#
UserComponent = require('components/pinboards/user')


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
    @cursor.pin.deref(false) and @cursor.me.deref(false)


  componentWillMount: ->
    @cursor =
      pin:          PinStore.cursor.items.cursor(@props.uuid)
      me:           UserStore.me()

    @fetch() unless @isLoaded()


  renderInsightAuthor: (author_id) ->
    <UserComponent uuid={ author_id } />


  renderInsight: (pin) ->
    return null unless pin.deref(false) or pin.get('content')

    isMine = pin.get('user_id') == @cursor.me.get('uuid')

    classList = cx
      insight:  'true'
      mine:     isMine

    <div className={ classList }>
      <p dangerouslySetInnerHTML={ __html: pin.get('content') } />
      { @renderInsightAuthor(pin.get('user_id')) unless isMine }
    </div>


  render: ->
    return null unless @isLoaded()

    <section className="pin">
      { @renderInsight(@cursor.pin) }
      { @renderInsight(PinStore.cursor.items.cursor(@cursor.pin.get('parent_id')) ) }
    </section>
