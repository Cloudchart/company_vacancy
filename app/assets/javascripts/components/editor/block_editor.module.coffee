# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx = React.addons.classSet

BlockStore = require('stores/block_store')

BlockActions = require('actions/block_actions')
BlockableActions = require('actions/mixins/blockable_actions')

SortableList = require('components/shared/sortable_list')
SortableListItem  = require('components/shared/sortable_list_item')

BlockComponents =
  Picture:    require('components/editor/picture')
  Paragraph:  require('components/editor/paragraph')
  Person:     require('components/editor/person')
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

        <SortableListItem key={block_key}>
          <section key={block_key} className={SectionClassNames[block.kind || block.identity_type]}>
            {@getDestroyLink(block.uuid)}
            <BlockComponent
              key={block_key}
              company_id={@props.company_id}
              readOnly={@props.readOnly}
              blockKind={block.kind || block.identity_type}
            />
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
    
    item = (name, key) =>
      <li key={key} onClick={@handleChooseBlockTypeClick.bind(@, key)}>{name}</li>
    
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

  buildParagraph: ->
    new_block_key = BlockStore.create({ owner_id: @props.owner_id, owner_type: @props.owner_type, identity_type: 'Paragraph', position: 0 })
    setTimeout => BlockableActions.createBlock(new_block_key, BlockStore.get(new_block_key).toJSON())


  # Handlers
  # 
  handleChooseBlockTypeClick: (identity_type) ->
    # -- temporary solution for quotes and kpi's
    kind = null
    if identity_type.match(/Quote|KPI/)
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

    @setState({ position: null })


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
    @buildParagraph() if @props.buildParagraph and @state.blocks.length == 0

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  getDefaultProps: ->
    buildParagraph: false

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    blocks: BlockStore.filter (block) => block.owner_id == props.owner_id

  getInitialState: ->
    state = @getStateFromStores(@props)
    state.position = null
    state

  render: ->
    return null unless @state.blocks

    classes = @props.classForArticle
    classes += ' draggable' unless @props.readOnly

    blocks = _.map @gatherBlocks(), (block, i) =>
      [
        @getSectionPlaceholder(i)
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
      {@getSectionPlaceholder(blocks.length)}
    </SortableList>

# Exports
# 
module.exports = MainComponent
