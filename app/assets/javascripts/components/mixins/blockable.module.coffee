# @cjsx React.DOM

SortableListItem  = require('components/shared/sortable_list_item')
SectionWrapper = require('components/shared/section_wrapper')

BlockStore = require('stores/block_store')

BlockActions = require('actions/block_actions')
BlockableActions = require('actions/mixins/blockable_actions')

module.exports =

  handleChooseBlockTypeClick: (identity_type) ->
    _.chain(@state.blocks)
      .filter (block) => block.position >= @state.position
      .each (block) => BlockStore.update(block.uuid, { position: block.position + 1 })

    key = BlockStore.create({ owner_id: @props.id, owner_type: @state.owner_type, identity_type: identity_type, position: @state.position })

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
    
    BlockActions.reposition(@props.id, ids)


  handlePlaceholderClick: (position) ->
    @setState({ position: position })


  handleCancelBlockCreateClick: ->
    @setState({ position: null })


  getSectionPlaceholder: (position) ->
    cancel_item = =>
      <li key="cancel" className="cancel">
        <i className="fa fa-times-circle" onClick={@handleCancelBlockCreateClick.bind(@, position)} />
      </li>
    
    item = (type, key) =>
      <li key={key} onClick={@handleChooseBlockTypeClick.bind(@, type)}>{key}</li>
    
    content = unless @state.readOnly
      if @state.position == position
        items = _.map(@identityTypes(), item) ; items.push(cancel_item())
        <ul>{items}</ul>
      else
        <figure onClick={@handlePlaceholderClick.bind(@, position)}>
          <i className="fa fa-plus" />
        </figure>
    
    <section className="placeholder">{content}</section>


  gatherBlocks: ->
    _.chain(@state.blocks)
      .sortBy(['position'])
      .map (block) =>
        key = block.getKey()
        <SortableListItem key={key}>
          <SectionWrapper ref={key} key={key} company_id={@state.company.uuid} readOnly={@state.readOnly} />
        </SortableListItem>
      .value()
