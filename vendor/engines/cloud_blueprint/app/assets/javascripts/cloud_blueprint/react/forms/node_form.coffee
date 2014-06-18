##= require ./buttons

# Shortcuts
#
tag = React.DOM


#
# Chart Id Field
#
ChartIDField = (value) ->
  (tag.input {
    type:   'hidden'
    name:   'chart_id'
    value:  value
  })


#
# Parent Id Field
#
ParentIDField = (value) ->
  (tag.input {
    type:   'hidden'
    name:   'parent_id'
    value:  value
  })


#
# Position Field
#
PositionField = (value) ->
  (tag.input {
    type:   'hidden'
    name:   'position'
    value:  value
  })


#
# Title Field
#
TitleField = (value, callback) ->
  (tag.input {
    type:           'text'
    name:           'title'
    placeholder:    'Title'
    className:      'blueprint'
    autoFocus:      true
    autoComplete:   'off'
    value:          value
    required:       true
    onChange:       callback
  })


#
# Color selector
#
ColorSelector = (colors, value, callback) ->
  inputs = _.map colors, (color, index) ->
    (tag.label {
      key: index
      style:
        backgroundColor: colors[index]
    },
      (tag.input {
        type:           'radio'
        name:           'color_index'
        value:          index
        defaultChecked: value == index
        onChange:       callback
      })
      (tag.i { className: 'fa fa-star' })
    )
  
  (tag.div { className: 'color-indices' },
    inputs
  )


#
#
#

Node = React.createClass


  getInitialState: ->
    @props.model.attributes
  
  
  onTitleChange: (event) ->
    @setState
      title: event.target.value
  

  onColorIndexChange: (event) ->
    @setState
      color_index: event.target.value


  missingField: ->
    _.find(@getDOMNode().querySelectorAll('[required]'), (field) -> !field.value)
    
  
  onSubmit: (event) ->
    event.preventDefault()
    
    return missing_field.focus() and false if missing_field = @missingField()
    
    if @props.model.is_persisted()
      @props.model.set_attributes(@state)
      Arbiter.publish("#{@props.model.constructor.broadcast_topic()}/update")
    else
      @props.model.constructor.create(@state)
      Arbiter.publish("#{@props.model.constructor.broadcast_topic()}/create")
    
    @props.model.constructor.sync()
    
    cc.ui.modal.close()
      
  
  
  onDelete: (event) ->
    event.stopPropagation()
    
    @props.model.destroy()
    @props.model.constructor.sync()
    #Arbiter.publish("#{@props.model.constructor.broadcast_topic()}/update")
    cc.ui.modal.close()


  render: ->
    (tag.form {
      className: 'node'
      onSubmit: @onSubmit
      style:
        borderColor: @props.colors[@state.color_index]
    },
      (ChartIDField   @state.chart_id),
      (ParentIDField  @state.parent_id),
      (PositionField  @state.position),
      (tag.section { className: 'title' },
        (TitleField @state.title, @onTitleChange)
      )
      (cc.blueprint.react.forms.Buttons { model: @props.model, onDelete: @onDelete },
        (ColorSelector @props.colors, @state.color_index, @onColorIndexChange)
      )
    )

#
#
#

_.extend @cc.blueprint.react.forms,
  Node: Node
