# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
BlockActions    = require('actions/block_actions')
CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')

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

    (tag.section {
      key:        block.getKey()
      className:  SectionClassNames[block.identity_type]
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

  (tag.section {
    className:  'placeholder'
  },
    
    if @state.position == position
      (tag.ul null,
      
        _.map IdentityTypes, (identityType, key) =>
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
      .sortBy(['position'])
      .map (block) =>
        component = BlockComponents[block.identity_type]

        (component {
          key:        block.getKey()
          block:      block
          readOnly:   @state.company.is_read_only
        })

        (SectionWrapperComponent {
          key:      block.getKey()
          readOnly: @state.company.is_read_only
        })

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
