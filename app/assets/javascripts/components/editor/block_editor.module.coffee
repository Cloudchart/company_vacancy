# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx = React.addons.classSet

BlockStore       = require('stores/block_store')

BlockActions     = require('actions/block_actions')
BlockableActions = require('actions/mixins/blockable_actions')

SortableList     = require('components/shared/sortable_list')
SortableListItem = require('components/shared/sortable_list_item')

Wrapper          = require('components/shared/wrapper')
Hint             = require('components/shared/hint')
renderHint       = require('utils/render_hint')

BlockComponents =
  Picture:    require('components/editor/picture')
  Paragraph:  require('components/editor/paragraph')
  Person:     require('components/editor/block_person')
  Quote:      require('components/editor/quote')
  Vacancy:    require('components/editor/vacancy')

SectionClassNames =
  Picture:    'picture'
  Paragraph:  'paragraph'
  Person:     'people'
  Vacancy:    'vacancies'
  Quote:      'quote'
  KPI:        'kpi'

SectionPlaceholderItemNames = 
  Picture:    'Picture'
  Paragraph:  'Text'
  Quote:      'Quote'
  KPI:        'KPI'
  Person:     'People'
  Vacancy:    'Vacancies'

Hints =
  Quote: renderHint("quote")
  Paragraph: renderHint("paragraph")

# Main
# 
MainComponent = React.createClass

  # mixins: []

  # Helpers
  # 
  gatherBlocks: ->
    _.chain(@state.blocks)
      .reject (block) => @props.readOnly and BlockComponents[block.identity_type].isEmpty(block.getKey())
      .sortBy(['position'])
      .map (block) =>
        BlockComponent = BlockComponents[block.identity_type]
        block_key = block.getKey()

        <SortableListItem uuid={block_key} key={block_key}>
          <section key={block_key} className={SectionClassNames[block.kind || block.identity_type]}>
            {@getDestroyLink(block.uuid)}
            <Wrapper className="editor" isWrapped={ !@props.readOnly } >
              <BlockComponent
                uuid={block_key}
                company_id={@props.company_id}
                readOnly={@props.readOnly}
                blockKind={block.kind || block.identity_type} />
              <Hint 
                content = { Hints[block.kind || block.identity_type] }
                visible = { !@props.readOnly && block.owner_type == "Post" && !!Hints[block.kind || block.identity_type] } />
            </Wrapper>
          </section>
        </SortableListItem>

      .value()

  
  getDestroyLink: (block_id) ->
    return null if @props.readOnly
    <i className="fa fa-times remove" onClick={@handleBlockDestroyClick.bind(@, block_id)}></i>


  getSectionPlaceholder: (position) ->
    cancel_item = =>
      <li key="cancel" className="cancel">
        <i className="fa fa-times-circle" onClick={@handleCancelBlockCreateClick.bind(@, position)} />
      </li>
    
    item = (name, uuid) =>
      <li uuid={uuid} key={uuid} onClick={@handleChooseBlockTypeClick.bind(@, uuid)}>{name}</li>
    
    content = unless @props.readOnly
      if @state.position == position
        items = _.map(@getIdentityTypes(), item) ; items.push(cancel_item())
        <ul>{items}</ul>
      else
        <figure onClick={@handlePlaceholderClick.bind(@, position)}>
          <i className="cc-icon cc-plus" />
        </figure>
    
    <section className="placeholder">{content}</section>


  getIdentityTypes: ->
    _.pick SectionPlaceholderItemNames, (name, key) => _.contains(@props.editorIdentityTypes, key)


  # Handlers
  # 
  handleChooseBlockTypeClick: (identity_type) ->
    # -- temporary solution for quotes and kpi's
    kind = null
    if identity_type.match(/KPI/)
      kind = identity_type
      identity_type = 'Paragraph'
    # --

    _.chain(@state.blocks)
      .filter (block) => block.position >= @state.position
      .each (block) => BlockStore.update(block.uuid, { position: block.position + 1 })

    key = BlockStore.create(
      owner_id: @props.owner_id 
      owner_type: @props.owner_type
      identity_type: identity_type
      position: @state.position
      kind: kind
    )

    BlockableActions.createBlock(key, BlockStore.get(key).toJSON())


  handleSortableChange: (key, currIndex, nextIndex) ->
    [blocks, offset] = if currIndex > nextIndex
      [
        _.filter @state.blocks, (block) -> block.position < currIndex and block.position >= nextIndex
        +1
      ]
    else
      [
        _.filter @state.blocks, (block) -> block.position > currIndex and block.position <= nextIndex
        -1
      ]
    
    _.each blocks, (block) ->
      BlockStore.update(block.getKey(), { position: block.position + offset })
    
    BlockStore.update(key, { position: nextIndex })
    
    BlockStore.emitChange()


  handleSortableUpdate: ->
    ids = _.chain(@state.blocks)
      .sortBy 'position'
      .invoke 'getKey'
      .value()
    
    BlockActions.reposition(@props.owner_id, ids)


  handlePlaceholderClick: (position) ->
    @setState({ position: position })

  handleCancelBlockCreateClick: ->
    @setState({ position: null })

  handleBlockDestroyClick: (uuid, event) ->
    BlockActions.destroy(uuid) if confirm('Are you sure?')


  # Lifecycle Methods
  # 
  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    blocks = BlockStore.filter (block) -> block.owner_id == props.owner_id
    position = if blocks.length is 0 and @props.owner_type is 'Post'then 0 else null

    blocks: blocks
    position: position

  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    return null unless @state.blocks

    classes = @props.classForArticle
    classes += ' draggable' unless @props.readOnly

    blocks = _.map @gatherBlocks(), (block, i) =>
      [
        @getSectionPlaceholder(i) if !@props.readOnly
        block
      ]

    <SortableList
      component = {tag.article}
      className = {classes}
      onOrderChange = {@handleSortableChange}
      onOrderUpdate = {@handleSortableUpdate}
      readOnly = {@props.readOnly}
      dragLockX
    >
      {blocks}

      {@getSectionPlaceholder(blocks.length) if !@props.readOnly}
    </SortableList>

# Exports
# 
module.exports = MainComponent
