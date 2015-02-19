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


# Utils
#
fuzzyDate = require('utils/fuzzy_date')


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


  handleClick: (event) ->
    event.preventDefault()

    window.location = @cursor.post.get('url')


  componentWillMount: ->
    @cursor =
      post:     PostStore.cursor.items.cursor(@props.uuid)
      blocks:   BlockStore.cursor.items.filterCursor (item) => item.get('owner_id') == @props.uuid

    @fetch() unless @isLoaded()


  renderDate: ->
    return unless date = fuzzyDate.format(@cursor.post.get('effective_from'), @cursor.post.get('effective_till'))

    <div className="date">{ date }</div>


  renderTitle: ->
    return unless @cursor.post.get('title', false)

    <div className="title" dangerouslySetInnerHTML={ __html: @cursor.post.get('title') } />


  renderDateAndTitle: ->
    <section className="title">
      { @renderDate() }
      { @renderTitle() }
    </section>


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
        null


  renderBlocks: ->
    @gatherBlocks().map(@renderBlock)


  render: ->
    return null unless @isLoaded()

    <article className="pinnable post-preview link" onClick={ @handleClick }>
      { @renderDateAndTitle() }
      { @renderBlocks().toArray() }
    </article>
