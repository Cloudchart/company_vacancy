# Imports
#
tag           = cc.require('react/dom')
colors        = cc.require('react/identities/person/colors')
LetterAvatar  = cc.require('react/shared/letter-avatar')


# Name Input Component
#
NameInputComponent = React.createClass


  onChange: (event) ->
    @setState
      value: event.target.value


  getDefaultProps: ->
    placeholder: 'Name Surname'


  getInitialState: ->
    value: @props.name
  
  
  componentDidMount: ->
    @getDOMNode().focus() if @props.initialy_active
  
  
  shouldComponentUpdate: (nextProps, nextState) ->
    return nextState.value != @state.value
  
  
  componentDidUpdate: ->
    @props.onChange({ target: { value: @state.value }}) if @props.onChange instanceof Function


  render: ->
    (tag.input {
      type:         'text'
      name:         'full_name'
      className:    'cloud'
      autoComplete: 'off'
      value:        @state.value
      placeholder:  @props.placeholder
      onChange:     @onChange
    })


# Main Component
#
MainComponent = React.createClass


  onSaveDone: (json) ->
    if json.redirect_to
      window.location.href = json.redirect_to
    else
      @setState
        full_name: json.full_name
  
  
  onSaveFail: ->
    console.log 'fail'


  onSubmit: (event) ->
    event.preventDefault()
    
    data = new FormData
    data.append "user[full_name]", @state.full_name
    
    $.ajax
      url:        @props.user.profile_activation_url
      type:       'PUT'
      dataType:   'json'
      data:       data
      contentType:  false
      processData:  false
    .done @onSaveDone
    .fail @onSaveFail
    
  
  onNameChange: (event) ->
    @setState
      full_name: event.target.value
  
  
  getInitialState: ->
    full_name: @props.user.full_name


  render: ->
    (tag.form {
      onSubmit: @onSubmit
    },
    
      (tag.aside { className: 'avatar' },
        (LetterAvatar { string: @state.full_name })
      )
      
      (tag.label { className: 'name' },
        (NameInputComponent {
          name:             @props.user.full_name
          onChange:         @onNameChange
        })
      )
              
      (tag.button { className: 'orgpad'},
        'Start using OrgPad'
        (tag.i { className: 'fa fa-magic' })
      )
      
    )


# Exports
#
cc.module('react/profile/activation/form').exports = MainComponent
