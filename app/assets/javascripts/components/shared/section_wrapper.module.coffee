# @cjsx React.DOM

# Imports
# 
tag = React.DOM

BlockStore = require('stores/block_store')
BlockActions = require('actions/block_actions')

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

# Main
# 
Component = React.createClass

  # Helpers
  # 
  handleBlockRemove: ->
    return if @props.readOnly
    
    BlockActions.destroy(@props.key) if confirm('Are you sure?')

  # Handlers
  # 
  # handleThingClick: (event) ->

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

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
        className:  'fa fa-times remove '
        onClick:    @handleBlockRemove
      }) unless @props.readOnly
  
      # Block
      #
      (BlockComponent {
        key:        block.getKey()
        company_id: @props.company_id
        readOnly:   @props.readOnly
      })
    )

# Exports
# 
module.exports = Component
