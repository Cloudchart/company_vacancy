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
PinnablePostCompanyHeader = require('components/pinnable/header/post_company')
PinButton                 = require('components/pinnable/pin_button')

Blocks =
  Paragraph:  require('components/pinnable/block/paragraph')
  Picture:    require('components/pinnable/block/picture')
  People:     require('components/pinnable/block/people')
  Quote:      require('components/pinnable/block/quote')


# Utils
#
fuzzyDate = require('utils/fuzzy_date')

trimDots    = require('utils/trim_string').trimDots
trimBreak   = require('utils/trim_string').trimBreak


# Exports
#
module.exports = React.createClass

  displayName: 'PinnablePost'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    uuid:        React.PropTypes.string.isRequired
    withContent: React.PropTypes.bool

  getDefaultProps: ->
    withContent: true

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
            },
            pins
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('post'), { id: @props.uuid })


  isLoaded: ->
    @cursor.post.deref(false)

  gatherPinAttributes: (insight) ->
    pinnable_id:    @props.uuid
    pinnable_type:  'Post'
    title:          @cursor.post.get('title')

  gatherBlocks: ->
    @cursor.blocks
      .sortBy (block) -> block.get('position')
      .take(2)

  isPostTruncated: ->
    @cursor.blocks.deref([]).size > 2 || 
    @gatherBlocks().some (block) => @isBlockTruncated(block)

  isBlockTruncated: (block) ->
    return false if block.get('identity_type') != 'Paragraph'
    return false unless (paragraph = @getParagraphByBlock(block))

    paragraph.get('content').match(/<div>(.*?)<\/div>/ig).length > 1

  trimDotsInParagraph: (content) ->
    trimDots(trimBreak(content))

  getTruncatedParagraph: (block) ->
    return null unless (paragraph = @getParagraphByBlock(block))

    content = paragraph.get('content').match(/<div>(.*?)<\/div>/i)[1].trim()

    content = if @isPostTruncated() then @trimDotsInParagraph(content) else content

    "<span>#{content}</span>"

  getParagraphByBlock: (block) ->
    ParagraphStore.findByOwner(type: 'Block', id: block.get('uuid'))

  isPostPreviewWithParagraphs: ->
    @gatherBlocks().some (block) => block.get('identity_type') == 'Paragraph'


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      post:     PostStore.cursor.items.cursor(@props.uuid)
      blocks:   BlockStore.cursor.items.filterCursor (item) => item.get('owner_id') == @props.uuid

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderReadMore: ->
    return null unless @isPostTruncated() && !@isPostPreviewWithParagraphs()

    <span className="read-more">More</span>

  renderDate: ->
    return unless date = fuzzyDate.format(@cursor.post.get('effective_from'), @cursor.post.get('effective_till'))

    <div className="date">{ date }</div>

  renderControls: ->
    <ul className="round-buttons">
      <PinButton {...@gatherPinAttributes()} />
    </ul>

  renderOwnerHeader: ->
    switch @cursor.post.get('owner_type')

      when 'Company'
        <PinnablePostCompanyHeader uuid={ @cursor.post.get('owner_id') } />

      else
        throw new Error("Pinnable Header: Unknown owner type '#{@cursor.post.get('owner_type')}' for pinnable type 'Post'")

  renderTitle: ->
    return unless @cursor.post.get('title', false)

    <header>
      { @renderControls() }
      <div className="title" dangerouslySetInnerHTML={ __html: @cursor.post.get('title') } />
    </header>

  renderBlock: (block) ->
    switch block.get('identity_type')
      when 'Paragraph'
        paragraph = @getParagraphByBlock(block)
        <Blocks.Paragraph key={ block.get('uuid') } text={ @getTruncatedParagraph(block) } truncated = { @isPostTruncated() } />

      when 'Picture'
        picture = PictureStore.findByOwner(type: 'Block', id: block.get('uuid'))
        <Blocks.Picture key={ block.get('uuid') } item={ picture } />

      when 'Person'
        peopleIds = PersonStore.filterForBlock(block.get('uuid')).map((person) -> person.get('uuid')).toSeq()
        <Blocks.People key={ block.get('uuid') } ids={ peopleIds } showLink={ false } />

      when 'Quote'
        quote = QuoteStore.findByOwner(type: 'Block', id: block.get('uuid'))
        <Blocks.Quote key={ block.get('uuid') } item={ quote } />

      else
        null

  renderBlocks: ->
    return null unless @props.withContent

    @gatherBlocks().map(@renderBlock).toArray()


  render: ->
    return null unless @isLoaded()

    <article className="pinnable post-preview link">
      <a className="for-group" href={ @cursor.post.get('post_url') } >
        { @renderTitle() }
        { @renderBlocks() }
        { @renderOwnerHeader() }
        { @renderReadMore() }
      </a>
    </article>
