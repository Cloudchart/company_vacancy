# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PostStore       = require('stores/post_store.cursor')
BlockStore      = require('stores/block_store.cursor')
ParagraphStore  = require('stores/paragraph_store.cursor')
PictureStore    = require('stores/picture_store.cursor')
PersonStore     = require('stores/person_store.cursor')
QuoteStore      = require('stores/quote_store')


# Components
#
Owners =
  'Company': null


Blocks =
  Paragraph:  require('components/pinnable/block/paragraph')
  Picture:    require('components/pinnable/block/picture')
  People:     require('components/pinnable/block/people')
  Quote:      require('components/pinnable/block/quote')


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
              quote {
                person
              },
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


  renderBlock: (block) ->
    switch block.get('identity_type')

      when 'Paragraph'
        paragraph = ParagraphStore.findByOwner(type: 'Block', id: block.get('uuid'))
        <Blocks.Paragraph key={ block.get('uuid') } item={ paragraph } />


      when 'Picture'
        picture = PictureStore.findByOwner(type: 'Block', id: block.get('uuid'))
        <Blocks.Picture key={ block.get('uuid') } item={ picture } />


      when 'Person'
        people = PersonStore.filterForBlock(block.get('uuid'))
        <Blocks.People key={ block.get('uuid') } items={ people } />


      when 'Quote'
        quote = QuoteStore.findByOwner(type: 'Block', id: block.get('uuid'))
        <Blocks.Quote key={ block.get('uuid') } item={ quote } />
      else
        console.log block.get('identity_type')
        null


  renderBlocks: ->
    @gatherBlocks().map(@renderBlock)


  render: ->
    return null unless @isLoaded()

    <article className="pinnable post-preview">
      { @renderBlocks().toArray() }
    </article>
