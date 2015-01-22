# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
CompanyStore  = require('stores/company_store.cursor')
PostStore     = require('stores/post_store.cursor')
BlockStore    = require('stores/block_store.cursor')


# Components
#

PostPreviewCompanyHeaderComponent = require('components/pinnable/post_preview_company')

BlockComponent = require('components/pinnable/block')


# Exports
# 
module.exports = React.createClass

  displayName: 'PinnablePostPreview'
  
  
  mixins: [GlobalState.mixin]
  
  
  statics:
    getCursor: (pin) ->
      companies:  CompanyStore.cursor.items
      post:       PostStore.cursor.items.cursor([pin.get('pinnable_id')])
      blocks:     BlockStore.cursor.items
  
  
  renderPinContent: ->
    if content = @props.pin.get('content')
      <section className="pin-content" dangerouslySetInnerHTML={ __html: content } />
  
  
  
  renderPostTitle: ->
    if title = @props.cursor.post.get('title')
      <header dangerouslySetInnerHTML={ __html: title } />
  
  
  renderBlocks: ->
    if @state.blocks.size > 0
      
      components = @state.blocks.toSeq().map (block) ->
        uuid = block.get('uuid')
        BlockComponent({ key: uuid, uuid: uuid, cursor: BlockStore.cursor.items.cursor(uuid) })
      
      components.take(2).toArray()
  
  
  renderPreview: ->
    <div className="preview">
      { @renderPostTitle() }
      { @renderBlocks() unless @props.skipBlocks }
    </div>
  
  
  onGlobalStateChange: ->
    @setState @getStateFromStores()
  
  
  getStateFromStores: ->
    company:  @props.cursor.companies.get(@props.cursor.post.get('owner_id'))
    blocks:   @props.cursor.blocks.filter((block) => block.get('owner_id') == @props.uuid ).sortBy((block) -> block.get('position'))
  
  
  getInitialState: ->
    @getStateFromStores()
  

  renderCompany: ->
    if @state.company
      PostPreviewCompanyHeaderComponent
        pin:          @props.pin
        company:      @state.company
        onUnpinClick: @props.onUnpinClick 
  
  
  render: ->
    return null unless @props.cursor.post.deref()

    <div className="pinnable-post-preview">
      { @renderCompany() }
      { @renderPinContent() }
      { @renderPreview() }
    </div>
