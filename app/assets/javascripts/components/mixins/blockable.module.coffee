# @cjsx React.DOM

tag = React.DOM

BlockStore = require('stores/block_store')

BlockActions = require('actions/block_actions')
BlockableActions = require('actions/mixins/blockable_actions')

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


  handleBlockDestroyClick: (uuid, event) ->
    BlockActions.destroy(uuid) if confirm('Are you sure?')


  getDestroyLink: (block_id) ->
    return null if @state.readOnly
    <i className="fa fa-times remove" onClick={@handleBlockDestroyClick.bind(@, block_id)}></i>


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
      .reject (block) => @state.readOnly and BlockComponents[block.identity_type].isEmpty(block.getKey())
      .sortBy(['position'])
      .map (block) =>
        BlockComponent = BlockComponents[block.identity_type]
        block_key = block.getKey()

        <SortableListItem key={block_key}>
          <section key={block_key} className={SectionClassNames[block.identity_type]}>
            {@getDestroyLink(block.uuid)}
            <BlockComponent
              key={block_key}
              company_id={@state.company.id}
              readOnly={@state.readOnly}
            />
          </section>
        </SortableListItem>

      .value()
