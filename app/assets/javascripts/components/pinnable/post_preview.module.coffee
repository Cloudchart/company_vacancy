# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore      = require('stores/pin_store')
CompanyStore  = require('stores/company_store.cursor')
PostStore     = require('stores/post_store.cursor')
BlockStore    = require('stores/block_store.cursor')
UserStore     = require('stores/user_store.cursor')


# Components
#

PostPreviewCompanyHeaderComponent = require('components/pinnable/post_preview_company')

BlockComponent = require('components/pinnable/block')

Avatar = require('components/avatar')


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
    company:    @props.cursor.companies.get(@props.cursor.post.get('owner_id'))
    blocks:     @props.cursor.blocks.filter((block) => block.get('owner_id') == @props.uuid ).sortBy((block) -> block.get('position'))
    parentPin:  PinStore.cursor.items.cursor(@props.pin.get('parent_id'))
  
  
  getInitialState: ->
    @getStateFromStores()
  

  renderCompany: ->
    if @state.company
      PostPreviewCompanyHeaderComponent
        pin:          @props.pin
        company:      @state.company
        onUnpinClick: @props.onUnpinClick
  
  
  renderParentPinUser: ->
    user = UserStore.cursor.items.cursor(@state.parentPin.get('user_id'))
    
    return unless user.deref()

    <div className="user">
      <aside>
        <Avatar value={ user.get('full_name') } backgroundColor="transparent" avatarURL={ user.get('avatar_url') }/>
      </aside>
      <section>
        <p className="name">{ user.get('full_name') }</p>
        <p className="occupation">{ user.get('occupation') }</p>
      </section>
    </div>
  
  
  renderParentPin: ->
    return unless @state.parentPin.deref()
    
    <div className="parent">
      <p>{ @state.parentPin.get('content') }</p>
      { @renderParentPinUser() }
    </div>
  
  
  render: ->
    return null unless @props.cursor.post.deref()

    <div className="pinnable-post-preview">
      { @renderCompany() }
      { @renderParentPin() }
      { @renderPinContent() }
      { @renderPreview() }
    </div>
