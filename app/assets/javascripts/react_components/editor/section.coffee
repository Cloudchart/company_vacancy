#
#
tag = React.DOM


# Section title input component
#
# Properties
#
#   value:        initial value
#   placeholder:  placeholder for empty value
#   url:          url for ajax request
#   key:          key for ajax requests
#   owner:        owner key for ajax request
#
SectionTitleInputComponent = React.createClass


  getInitialState: ->
    value:            @props.value
    is_editing:       false
    should_update:    false
    is_synchronizing: false


  onChange: (event) ->
    @setState
      value: event.target.value
  
  
  onFocus: (event) ->
    @setState
      is_editing: true
  

  onBlur: (event) ->
    @setState
      is_editing:     false
      should_update:  true
  
  
  componentDidUpdate: ->
    @save() if @state.should_update
  
  
  save: ->
    @setState
      should_update:    false
      is_synchronizing: true

    attributes              = {}
    attributes[@props.key]  = @state.value

    data                    = {}
    data[@props.owner]      = { sections_attributes: attributes }

    $.ajax
      url:      @props.company_url
      type:     'PUT'
      dataType: 'json'
      data: data


  render: ->
    (tag.input {
      type:           'text'
      autoComplete:   'off'
      disabled:       true
      placeholder:    @props.placeholder
      value:          @state.value
      onChange:       @onChange
      onFocus:        @onFocus
      onBlur:         @onBlur
    })


# Section component
#
# Properties:
#   title:        initial section title
#   placeholder:  placeholder for empty title
#   url:          url for ajax requests
#   key:          key for ajax requests
#   owner:        owner key for ajax requests
#
SectionComponent = React.createClass


  mixins: [cc.react.mixins.Droppable]
  
  
  doneCreateBlock: (json) ->
    @setState({ blocks: json })
  
  
  failCreateBlock: ->
    console.log 'fail'
  
  
  createBlock: (identity_type) ->
    $.ajax
      url:        @props.blocks_url
      type:       'POST'
      dataType:   'json'
      data:
        block:
          section:        @props.key
          position:       @state.drop_zone_index
          identity_type:  identity_type
    .done @doneCreateBlock
    .fail @failCreateBlock
  
  
  deleteBlock: (url) ->
    $.ajax
      url:      url
      type:     'DELETE'
      dataType: 'json'
    .done @doneCreateBlock
    .fail @failCreateBlock
  
  
  cleanDropZone: ->
    @setState({ drop_zone_index: null })


  onCCDropMove: (event) ->
    return unless _.contains(event.dataTransfer.types, 'block-type')
    
    event.preventDefault()
    
    components = _.chain(@state.blocks).filter((block) -> !block.is_locked).map((block) => @refs['block-' + block.uuid]).value()
    
    y = event.pageY - window.pageYOffset
    
    component = _.reduce components, (prev, curr) ->
      prev_bounds = prev.getDOMNode().getBoundingClientRect()
      curr_bounds = curr.getDOMNode().getBoundingClientRect()
      
      if Math.min(Math.abs(prev_bounds.top - y), Math.abs(prev_bounds.bottom - y)) < Math.min(Math.abs(curr_bounds.top - y), Math.abs(curr_bounds.bottom - y))
        prev
      else
        curr
      
    , components[0]
    
    position = if component
      bounds      = component.getDOMNode().getBoundingClientRect()
      component_y = bounds.top + bounds.height / 2
      component.props.position + if component_y < y then 1 else 0
    else
      @state.blocks.length
    
    @setState({ drop_zone_index: position })
    
  
  onCCDropLeave: (event) ->
    @cleanDropZone()
  
  
  onCCDropDrop: (event) ->
    @createBlock(event.dataTransfer.getData('block-type'))
    @cleanDropZone()


  onBlockDelete: (event) ->
    @deleteBlock(event.target.url)
    

  getInitialState: ->
    blocks:           @props.blocks
    drop_zone_index:  null
  
  
  gatherBlocks: ->
    blocks = @state.blocks.map (block_props) =>
      block_props.ref             = 'block-' + block_props.uuid
      block_props.key             = block_props.uuid
      block_props.onDelete        = @onBlockDelete
      block_props.collection_url  = switch block_props.identity_type
        when 'Person'   then @props.people_url
        when 'Vacancy'  then @props.vacancies_url
        else null

      cc.react.editor.blocks.Main(block_props)
    
    if (index = @state.drop_zone_index) != null
      blocks.splice(index, 0, cc.react.editor.blocks.Main({ key: 'drop-zone', identity_type: 'Drop Here' }))
    
    blocks


  render: ->
    titleInputComponent = SectionTitleInputComponent
      value:        @props.title
      placeholder:  @props.placeholder
      url:          @props.company_url
      key:          @props.key
      owner:        @props.owner
    
    (tag.section {
      'data-droppable': 'on'
    },
      (tag.a { name: @props.placeholder })
      (tag.header {},
        (titleInputComponent)
      )
      @gatherBlocks()
    )

# Expose Section component
#
@cc.react.editor.Section = SectionComponent
