##= require ./logo

# imports
#
tag = cc.require('react/dom')

ImageUploaderComponent  = cc.require('react/editor/image-uploader')
LogoComponent           = cc.require('react/company/logo')

KEY_ESC   = 27
KEY_ENTER = 13


# Input Component
#
InputComponent = React.createClass


  onChange: (event) ->
    @setState
      value: event.target.value
  
  
  onFocus: (event) ->
    @setState
      active: true
  

  onBlur: (event) ->
    @setState
      active: false
  
  
  onKeyUp: (event) ->
    switch event.which
      when KEY_ESC
        @setState
          value: @props.value
        @getDOMNode().blur()

      when KEY_ENTER
        @getDOMNode().blur()

  
  componentWillReceiveProps: (nextProps) ->
    @setState
      value: nextProps.value
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @props.onChange(@state.value) if @props.onChange instanceof Function and @props.value != @state.value and !@state.active and prevState.active 


  getInitialState: ->
    value: @props.value


  render: ->
    (tag.input {
      type:           'text'
      name:           @props.name
      value:          @state.value
      placeholder:    @props.placeholder
      autoComplete:   'off'
      onChange:       @onChange
      onFocus:        @onFocus
      onBlur:         @onBlur
      onKeyUp:        @onKeyUp
    })


# Main Component
#
MainComponent = React.createClass


  onSaveDone: (json) ->
    console.log json
    @setState
      name:         json.name
      description:  json.description
  
  
  onSaveFail: ->
    console.log 'fail'


  save: ->
    return unless @props.url
    
    data = ['name', 'description'].reduce(((memo, name) => memo.append("company[#{name}]", @state[name]) ; memo), new FormData)
    
    $.ajax
      url:          @props.url
      type:         'PUT'
      dataType:     'json'
      data:         data
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail


  gatherSections: ->
    @props.available_sections.map (section) ->
      (tag.a {
        key:  section.title
        href: "##{section.title}"
      }, section.title)


  onNameChange: (value) ->
    @setState
      name: if value.trim().length == 0 then @state.name else value
  
  
  onDescriptionChange: (value) ->
    @setState
      description: value
  
  
  getInitialState: ->
    name:         @props.name
    description:  @props.description
  
  
  componentDidUpdate: (prevProps, prevState) ->
    return @save() if ['name', 'description'].some((name) => prevState[name] != @state[name])


  render: ->
    (tag.header {},

      (LogoComponent { logo: @props.logo, url: @props.url })
      
      (tag.h1   {},
        (InputComponent {
          name:         'name'
          value:        @state.name
          onChange:     @onNameChange
          placeholder:  'Company name'
        })

        (tag.small {},
          (InputComponent {
            name:         'description'
            value:        @state.description
            onChange:     @onDescriptionChange
            placeholder:  'Company description'
          })
        )
      )
      (tag.nav  {}, @gatherSections())
    )


# Exports
#
cc.module('react/company/header').exports = MainComponent
