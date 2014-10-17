###
  Used in:

  cloud_blueprint/react/blueprint/chart
  cloud_blueprint/react/blueprint/node
###

##= require ./buttons

# Shortcuts
#
tag = React.DOM


NodeIdentityStore     = require('cloud_blueprint/stores/node_identity_store')


# Empty Identity Component
#
EmptyIdentityComponent = React.createClass

  render: ->
    (tag.li { className: 'placeholder', 'data-behaviour': 'droppable', 'data-id': @props.model.uuid },
      (tag.p {},
        "Drag people and vacancies here"
      )
    )


# Submit button
#
SubmitButton = (props, state) ->
  (tag.button { className: 'blueprint' },
    (tag.i { className: 'fa fa-check' })
    " "
    ["Create", "Update"][~~props.model.is_persisted()]
  )


# Delete button
#
DeleteButton = (props, state, onClick) ->
  (tag.a {
    href:       ''
    className:  'blueprint-button alert'
    onClick:    onClick
  },
    (tag.i { className: 'fa fa-times' })
    " Delete"
  )


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
TitleField = (value, callback, autofocus = false, is_required = true) ->
  (tag.input {
    type:           'text'
    name:           'title'
    placeholder:    'Title'
    className:      'blueprint'
    autoFocus:      autofocus
    autoComplete:   'off'
    value:          value
    required:       is_required
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


  componentDidMount: ->
    NodeIdentityStore.on('change', @refresh)
    Arbiter.subscribe "#{cc.blueprint.models.Identity.broadcast_topic()}/*", @refresh
  

  componentWillUnmount: ->
    NodeIdentityStore.off('change', @refresh)
    Arbiter.unsubscribe "#{cc.blueprint.models.Identity.broadcast_topic()}/*", @refresh


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
    
    Arbiter.publish('cc:blueprint:modal/hide')
      
  
  
  onDelete: (event) ->
    event.preventDefault()
    
    @props.model.destroy()
    @props.model.constructor.sync()

    cc.blueprint.react.modal.hide()
  
  
  
  gatherPeople: ->
    _.sortBy(@props.model.people(), ['last_name', 'first_name']).map (person) =>
      cc.blueprint.react.Identity { key: person.uuid, model: person, node: @props.model }
  

  gatherVacancies: ->
    @props.model.vacancies().map (vacancy) =>
      cc.blueprint.react.Identity { key: vacancy.uuid, model: vacancy, node: @props.model }


  refresh: ->
    @setState
      refreshed_at: + new Date

  render: ->
    people    = @gatherPeople()
    vacancies = @gatherVacancies()
    
    (tag.form {
      className: 'node'
      onSubmit: @onSubmit
      style:
        borderColor: @props.colors[@state.color_index]
    },
      (ChartIDField   @state.chart_id),
      (ParentIDField  @state.parent_id),
      (PositionField  @state.position),
      (tag.section { className: 'fields' },
        (TitleField @state.title, @onTitleChange, @props.model.is_new_record(), @props.model.identities().length == 0)
        (tag.ul { className: 'identities' },
          people
          vacancies
          (EmptyIdentityComponent @props) if @props.model.is_persisted()
        )
      )
      (tag.section { className: 'controls' },
        (DeleteButton @props, @state, @onDelete) if @props.model.can_be_deleted()
        (tag.div {}) unless @props.model.can_be_deleted()
        (ColorSelector @props.colors, @state.color_index, @onColorIndexChange)
        (SubmitButton @props, @state, @onSubmit)
      )
    )

#
#
#

_.extend @cc.blueprint.react.forms,
  Node: Node
