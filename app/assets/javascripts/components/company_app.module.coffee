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


# Main
#
Component = React.createClass


  gatherBlocks: ->
    _.chain(@state.blocks)
      .sortBy('position')
      .map (block) =>
        component = blockComponents[block.identity_type]
        (component {
          key:        block.uuid
          block:      block
          readOnly:   @props.readOnly
        })
      .value()


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
            
    )


# Exports
#
module.exports = Component
