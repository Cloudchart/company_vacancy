#
#
tag = React.DOM


# Section title input component
#
SectionTitleInputComponent = React.createClass

  getInitialState: ->
    value: @props.value


  onChange: (event) ->
    @setState
      value: event.target.value
  
  
  onBlur: (event) ->
    @props.onTitleChange(@state.value)


  render: ->
    (tag.input {
      type:         'text'
      autoComplete: 'off'
      placeholder:  @props.placeholder
      value:        @state.value
      onChange:     @onChange
      onBlur:       @onBlur
    })


# Undefined block component
#
UndefinedBlockComponent = React.createClass

  render: ->
    (tag.div {},
      "Unknow block "
      @props.identity_type
    )


# New block placeholder component
# 
NewBlockPlaceholderComponent = React.createClass

  render: ->
    (tag.div { className: 'new-block-placeholder' })


# Section component
#

SectionComponent = React.createClass


  mixins: [cc.react.mixins.Droppable]
  
  
  clearNewBlockPlaceholder: ->
    @setState
      new_block_position: null


  onCCDropEnter: (event) ->
    return if event.dataTransfer.types.indexOf('sidebar-blocks-item') == -1

    @setState
      new_block_position: @props.children.length
  
  
  onCCDropMove: (event) ->
    return if event.dataTransfer.types.indexOf('sidebar-blocks-item') == -1
    
    event.preventDefault()


  onCCDropLeave: (event) ->
    @clearNewBlockPlaceholder()
    
  
  onCCDropDrop: (event) ->
    @clearNewBlockPlaceholder()


  onTitleChange: (title) ->
    @props.onTitleChange() if @props.onTitleChange instanceof Function
  
  
  getInitialState: ->
    new_block_position: null

  
  title: ->
    @refs.title_input.state.value
  

  render: ->
    blocks = @props.children.map (props) =>
      if componentClass = cc.react.editor.blocks[props.identity_type]
        componentClass(props)
      else
        UndefinedBlockComponent(props)
    
    unless @state.new_block_position == null
      blocks.splice(@state.new_block_position, 0, (NewBlockPlaceholderComponent { key: 'new' }))
    
    
    (tag.section {
      'data-droppable': 'on'
    },
      (tag.header { 'data-id': @props.key },
        (SectionTitleInputComponent {
          ref:            'title_input'
          placeholder:    @props.title
          value:          @props.value
          onTitleChange:  @onTitleChange
        })
      )
      blocks...
    )


# Expose Section component
#

@cc.react.editor.SectionComponent = SectionComponent
