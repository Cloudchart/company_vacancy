# @cjsx React.DOM

# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
BlockActions    = require('actions/block_actions')
CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')

Sortable        = require('components/shared/sortable')

CompanyHeader   = require('components/company/header')

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


IdentityTypes =
  People:     'Person'
  Vacancies:  'Vacancy'
  Picture:    'Picture'
  Paragraph:  'Paragraph'



# Section Wrapper Component
#
SectionWrapperComponent = React.createClass


  handleBlockRemove: ->
    return if @props.readOnly
    
    BlockActions.destroy(@props.key) if confirm('Are you sure?')


  render: ->
    block           = BlockStore.get(@props.key)
    BlockComponent  = BlockComponents[block.identity_type]
    blockClassName  = SectionClassNames[block.identity_type]

    (tag.section {
      key:        block.getKey()
      className:  blockClassName
    },
  
      # Remove
      #
      (tag.i {
        className:  'fa fa-times-circle-o remove '
        onClick:    @handleBlockRemove
      }) unless @props.readOnly
  
      # Block
      #
      (BlockComponent {
        key:      block.getKey()
        readOnly: @props.readOnly
      })
    )


# Section Placeholder component
#
SectionPlaceholderComponent = (position) ->
  cancel_item = =>
    <li key="cancel" className="cancel">
      <i className="fa fa-times-circle" onClick={@onCancelBlockCreateClick.bind(@, position)} />
    </li>
  
  item = (type, key) =>
    <li key={key} onClick={@onChooseBlockTypeClick.bind(@, type)}>{key}</li>
  
  content = unless @props.readOnly
    if @state.position == position
      items = _.map(IdentityTypes, item) ; items.push(cancel_item())
      <ul>{items}</ul>
    else
      <figure onClick={@onPlaceholderClick.bind(@, position)}>
        <i className="fa fa-plus" />
      </figure>
  
  <section className="placeholder">{content}</section>
    

# Main
#
Component = React.createClass


  handleDragMove: (key, origin) ->
    delta = (top, bottom) -> Math.min(Math.abs(top - origin.y), Math.abs(bottom - origin.y))
    
    rectangles = _.reduce @refs, (memo, ref, key) ->
      memo.push({ key: key, bounds: ref.getDOMNode().getBoundingClientRect() })
      memo
    , []
  
  
  
  handleDragStart: (index) ->
    
  
  handleSortableChange: (data) ->
    blocks = @state.blocks[..]
    
    block = blocks.splice(data.from, 1)[0]
    blocks.splice(data.to, 0, block)
    
    @setState
      blocks: blocks


  gatherBlocks: ->
    _.chain(@state.blocks)
      #.sortBy(['position'])
      .map (block) =>
        key = block.getKey()
        <SectionWrapperComponent ref={key} key={key} readOnly={@state.company.is_read_only} />
      .value()
  
  
  onPlaceholderClick: (position) ->
    @setState({ position: position })
  
  
  onCancelBlockCreateClick: ->
    @setState({ position: null })
  
  
  onChooseBlockTypeClick: (type) ->
    _.chain(@state.blocks)
      .filter (block) => block.position >= @state.position
      .each (block) => BlockStore.update(block.uuid, { position: block.position + 1 })

    key = BlockStore.create({ owner_id: @props.key, owner_type: 'Company', identity_type: type, position: @state.position })

    CompanyActions.createBlock(key, BlockStore.get(key).toJSON())

    @setState({ position: null })


  getStateFromStores: ->
    company:  CompanyStore.get(@props.key)
    blocks:   BlockStore.filter (block) => block.owner_type == 'Company' and block.owner_id == @props.key
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    BlockStore.on('change', @refreshStateFromStores)
  

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    BlockStore.off('change', @refreshStateFromStores)
  
  
  getInitialState: ->
    state           = @getStateFromStores()
    state.position  = null
    state


  render: ->
    if @state.company
      blocks = _.map @gatherBlocks(), (block, i) =>
        [
          SectionPlaceholderComponent.call(@, i)
          block
        ]
      
      <Sortable selector="section:not(.placeholder)" onChange={@handleSortableChange} lockX>
        <article className="editor company company-2_0">
          <CompanyHeader
            key           = {@props.key}
            logotype_url  = {@state.company.logotype_url}
            name          = {@state.company.name}
            description   = {@state.company.description}
            readOnly      = {@state.company.is_read_only}
            can_follow    = {@state.company.can_follow}
            is_followed   = {@state.company.is_followed}
          />
          {blocks}
          {SectionPlaceholderComponent.call(@, blocks.length)}
        </article>
      </Sortable>

    else
      null


# Exports
#
module.exports = Component
