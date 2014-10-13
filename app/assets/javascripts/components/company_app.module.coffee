# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')

CompanyHeader   = require('components/company/header')

blockComponents =
  Picture:    require('components/editor/picture')
  Paragraph:  require('components/editor/paragraph')
  Person:     require('components/editor/person')
  Vacancy:    require('components/editor/vacancy')


FreshBlockComponent = require('components/editor/fresh')


identityTypes =
  People:     'Person'
  Vacancies:  'Vacancy'
  Picture:    'Picture'
  Paragraph:  'Paragraph'



# Section Placeholder component
#
SectionPlaceholderComponent = (position) ->

  (tag.section {
    className:  'placeholder'
  },
    
    if @state.position == position
      (tag.ul null,
      
        _.map identityTypes, (identityType, key) =>
          (tag.li {
            key:      key
            onClick:  @onChooseBlockTypeClick.bind(@, identityType)
          },
            key
          )
      
        (tag.li {
          className: 'cancel'
        },
          (tag.i {
            className: 'fa fa-times-circle'
            onClick:    @onCancelBlockCreateClick.bind(@, position)
          })
        )
      )
    else
      (tag.figure {
        onClick:    @onPlaceholderClick.bind(@, position)
      },
        (tag.i { className: 'fa fa-plus' })
      )
  )


# Main
#
Component = React.createClass


  gatherBlocks: ->
    _.chain(@state.blocks)
      .sortBy(['position', 'uuid'])
      .map (block) =>
        component = if block.uuid then blockComponents[block.identity_type] else FreshBlockComponent
        (component {
          key:        block.uuid
          block:      block
          readOnly:   @state.company.is_read_only
        }) if component
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
    @setState({ position: null })
    BlockStore.emitChange()


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
      blocks = @gatherBlocks()
      
      (tag.article {
        className: 'editor company company-2_0'
      },
    
        (CompanyHeader {
          key:          @props.key
          logotype_url: @state.company.logotype_url
          name:         @state.company.name
          description:  @state.company.description
          readOnly:     @state.company.is_read_only
          can_follow:   @state.company.can_follow
          is_followed:  @state.company.is_followed
        })
      
        _.map blocks, (block, i) =>
          [
            SectionPlaceholderComponent.call(@, i)
            block
          ]

        SectionPlaceholderComponent.call(@, blocks.length)
            
      )
    else
      (tag.noscript null)


# Exports
#
module.exports = Component
