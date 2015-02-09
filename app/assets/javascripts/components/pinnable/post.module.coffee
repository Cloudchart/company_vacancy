# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PostStore   = require('stores/post_store.cursor')
BlockStore  = require('stores/block_store.cursor')


# Components
#
Owners =
  'Company': null


# Exports
#
module.exports = React.createClass

  displayName: 'Pin'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      post: ->
        """
          Post {
            owner
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('post'), { id: @props.uuid })


  isLoaded: ->
    @cursor.post.deref(false) #and @cursor.blocks.count() > 0


  componentWillMount: ->
    @cursor =
      post:     PostStore.cursor.items.cursor(@props.uuid)
      blocks:   BlockStore.cursor.items.filterCursor (item) => item.get('owner_id') == @props.uuid

    @fetch() unless @isLoaded()


  getDefaultProps: ->
    cursor: {}


  renderOwner: ->
    <section className="owner">
      { @cursor.post.get('owner_type') }
    </section>


  renderPinContent: ->
    return unless @props.pin.get('content', false)

    <section className="pin-content">
      { @props.pin.get('content') }
    </section>


  render: ->
    return null unless @isLoaded()

    <article>
      { @renderOwner() }
      { @renderPinContent() }
    </article>
