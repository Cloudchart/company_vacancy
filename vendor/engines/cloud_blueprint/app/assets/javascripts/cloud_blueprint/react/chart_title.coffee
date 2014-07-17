# Imports
#
tag = React.DOM


# Main Component
#
MainComponent = React.createClass


  onSaveDone: (json) ->
    @setState
      value:          json.title
      prevValue:      json.title
      synchronizing:  false
  
  
  onSaveFail: ->
    @setState
      value:          @state.prevValue
      synchronizing:  false


  save: ->
    @setState
      should_save:    false
      synchronizing:  true
    
    $.ajax
      url:        @props.url
      type:       'PUT'
      dataType:   'json'
      data:
        chart:
          title:  @state.value
        only: ['title']
    .done @onSaveDone
    .fail @onSaveFail
  
  
  focus: ->
    @refs.input.getDOMNode().focus()
  
  
  blur: ->
    @refs.input.getDOMNode().blur()


  onChange: (event) ->
    @setState
      value: event.target.value
  
  
  onBlur: (event) ->
    @setState
      should_save: @state.value != @state.prevValue
  
  
  onKeyUp: (event) ->
    switch event.key
      when 'Escape'
        @setState({ value: @state.prevValue })
        @blur()
      when 'Enter'
        @blur()


  componentDidMount: ->
    @focus()  if @state.value == 'Default Chart'


  componentDidUpdate: ->
    @save()   if @state.should_save
    @focus()  if @state.value == 'Default Chart'


  getInitialState: ->
    value:      @props.title
    prevValue:  @props.title


  render: ->
    (tag.div { className: 'chart-title-editor' },
      (tag.input {
        ref:          'input'
        type:         'text'
        placeholder:  'Chart name'
        value:        @state.value
        onChange:     @onChange
        onBlur:       @onBlur
        onKeyUp:      @onKeyUp
      })
    )


# Exports
#
cc.module('blueprint/react/chart-title').exports = MainComponent
