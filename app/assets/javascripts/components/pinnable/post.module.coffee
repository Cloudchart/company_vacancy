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

  displayName: 'PinnablePost'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      post: ->
        """
          Post {
            company,
            blocks {
              quote,
              picture,
              paragraph,
              block_identities {
                identity
              }
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('post'), { id: @props.uuid })


  isLoaded: ->
    @cursor.post.deref(false)


  gatherBlocks: ->
    @cursor.blocks
      .sortBy (block) -> block.get('position')


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


  renderBlock: (block) ->
    <span key={ block.get('uuid') }>{ block.get('identity_type') }</span>


  renderBlocks: ->
    @gatherBlocks().map(@renderBlock)


  render: ->
    return null unless @isLoaded()

    <article className="pinnable post-preview">
      { @renderOwner() }
      { @renderBlocks().toArray() }
    </article>
