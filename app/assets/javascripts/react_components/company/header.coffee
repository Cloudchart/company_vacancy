##= require ./logo

# imports
#
tag = cc.require('react/dom')

ImageUploaderComponent  = cc.require('react/editor/image-uploader')
LogoComponent           = cc.require('react/company/logo')
backgroundColor         = cc.require('react/shared/letter-avatar/background-color')

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
    @setState
      name:         json.name
      description:  json.description
  
  
  onSaveFail: ->
    console.log 'fail'


  save: ->
    return unless @props.company_url
    
    data = ['name', 'description'].reduce(((memo, name) => memo.append("company[#{name}]", @state[name]) ; memo), new FormData)
    
    $.ajax
      url:          @props.company_url
      type:         'PUT'
      dataType:     'json'
      data:         data
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail


  gatherSections: ->
    sections = []

    sections.push(
      (tag.a {
        key: 'editor'
        id: 'editor'
        className: 'current' if @props.toggle_value == 'editor'
        href: '#'
        onClick: @onTabClick
      }, 'Company')
    )

    sections.push(
      (tag.a {
        key: 'burn_rate'
        id: 'burn_rate'
        className: 'current' if @props.toggle_value == 'burn_rate'
        href: '#'
        onClick: @onTabClick
      }, 'Burn rate') 
    ) if @props.is_editor or @props.is_trusted_reader

    sections.push(
      (tag.a {
        key: 'settings'
        id: 'settings'
        className: 'current' if @props.toggle_value == 'settings'
        href: ''
        onClick: @onTabClick
      }, 'Settings')
    )

    sections

  onTabClick: (event) ->
    event.preventDefault()
    @props.onChange(event.target.id) unless event.target.id == @props.toggle_value

  onNameChange: (value) ->
    @setState
      name: if value.trim().length == 0 then @state.name else value
  
  
  onDescriptionChange: (value) ->
    @setState
      description: value
  
  
  getInitialState: ->
    name:         @props.name         || ''
    description:  @props.description  || ''
  
  
  componentDidUpdate: (prevProps, prevState) ->
    return @save() if ['name', 'description'].some((name) => prevState[name] != @state[name])


  render: ->
    (tag.header {
      style:
        backgroundColor: backgroundColor(@state.name)
    },
      (tag.div { className: 'container' },
        (LogoComponent { logo: @props.logo, logotype: @props.logotype_url, url: @props.company_url })
      
        (tag.h1   {},
          (InputComponent {
            name:         'name'
            value:        @state.name
            onChange:     @onNameChange
            placeholder:  'Name'
          })

          (tag.small {},
            (InputComponent {
              name:         'description'
              value:        @state.description
              onChange:     @onDescriptionChange
              placeholder:  'Tap here to add short description'
            })
          )
        )
        (tag.nav  {}, @gatherSections()) if @props.is_editor or @props.is_public_reader or @props.is_trusted_reader
      )
    )


# Exports
#
cc.module('react/company/header').exports = MainComponent
