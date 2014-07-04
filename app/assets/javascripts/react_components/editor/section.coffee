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
      url:      @props.url
      type:     'PUT'
      dataType: 'json'
      data: data


  render: ->
    (tag.input {
      type:           'text'
      autoComplete:   'off'
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


  render: ->
    titleInputComponent = SectionTitleInputComponent
      value:        @props.title
      placeholder:  @props.placeholder
      url:          @props.url
      key:          @props.key
      owner:        @props.owner
    
    blocksComponents = []
    
    (tag.section {},
      (tag.header {},
        (titleInputComponent)
        (blocksComponents) if blocksComponents.length > 0
      )
    )

# Expose Section component
#
@cc.react.editor.Section = SectionComponent
