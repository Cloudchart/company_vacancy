# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')

CompanyHeader   = require('components/company/header')
BlockPicture    = require('components/editor/picture')


blockComponents =
  Picture: BlockPicture


# Main
#
Component = React.createClass


  gatherBlocks: ->
    _.map @state.blocks, (block) =>
      component = blockComponents[block.identity_type]
      (component {
        key:        block.uuid
        block:      block
        readOnly:   @props.readOnly
      })


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
    @getStateFromStores()


  render: ->
    (tag.article {
      className: 'company-2_0'
    },
    
      (CompanyHeader {
        key:          @props.key
        logotype_url: @state.company.logotype_url
        name:         @state.company.name
        description:  @state.company.description
      })
      
      @gatherBlocks()
      
      # (tag.section {
      # })
      #
      # 'Greatest And Brightest'
      #
      # (tag.div {
      #   className: 'paragraph'
      # },
      #   "Digital October hosts unique educational programs inviting top educators and experts from around the world. Entrepreneurs and investors get access to best networking opportunities in an informal atmosphere of our Progress Bar located right next to the conference."
      # )
      #
      #
      # (tag.header null,
      #   'Open Positions'
      # )
      #
      #
      # (tag.div {
      #   className: 'image'
      # },
      #   (tag.div {
      #     className: 'placeholder'
      #   },
      #     (tag.label null,
      #       (tag.h2 null,
      #         (tag.i { className: 'fa fa-picture-o' })
      #         "Product pucture goes here"
      #       )
      #       (tag.p null, "Use professional photography or graphics design.")
      #       (tag.p null, "Use pictures at least 1500 px wide with a ratio of 4:3.")
      #       (tag.p null, "1600x1200 px is a good start.")
      #     )
      #   )
      # )
      
    )


# Exports
#
module.exports = Component
