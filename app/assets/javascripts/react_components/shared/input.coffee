###
  Used in:

  cloud_blueprint/react/chart_title
  cloud_profile/react/settings/personal
###

#
#
tag = React.DOM


# Main Component
#
Component = React.createClass


  onSaveDone: (json) ->
    @setState
      value:          json[@props.readAttribute]
      prevValue:      json[@props.readAttribute]
      synchronizing:  false
  
  
  onSaveFail: (xhr) ->
    @setState
      value:          @state.prevValue 
      synchronizing:  false


  save: ->
    throw 'Unknown attribute name for read in InputComponent' unless @props.readAttribute
    throw 'Unknown attribute name for save in InputComponent' unless @props.saveAttribute
    
    return if @state.synchronizing
    
    @setState({ synchronizing: true })
    
    data = new FormData
    data.append(@props.saveAttribute, @state.value)
    
    $.ajax
      url:        @props.url
      data:       data
      type:       'PUT'
      dataType:   'json'
      contentType:  false
      processData:  false
    .done @onSaveDone
    .fail @onSaveFail


  focus: ->
    @getDOMNode().focus()
  
  
  blur: ->
    @getDOMNode().blur()


  onChange: (event) ->
    @setState({ value: event.target.value })
  

  onFocus: (event) ->
    @setState({ active: true })
  
  
  onBlur: (event) ->
    @setState({ active: false })
  
  
  onKeyUp: (event) ->
    switch event.key

      when 'Escape'
        @blur()
        @setState({ value: @state.prevValue })
      
      when 'Enter'
        @blur()
  
  
  componentDidUpdate: (prevProps, prevState) ->
    
    if @state.active and @state.value isnt prevState.value
      @props.onChange({ target: { value: @state.value }}) if @props.onChange instanceof Function
    
    if not @state.active and @state.value isnt @state.prevValue
      @props.onUpdate({ target: { value: @state.value }}) if @props.onUpdate instanceof Function
      @save() if @props.url
    

  componentWillReceiveProps: (nextProps) ->
    @setState({ value: nextProps.value, prevValue: nextProps.value }) unless @state.active


  getInitialState: ->
    value:      @props.value
    prevValue:  @props.value


  render: ->
    @transferPropsTo(
      (tag.input {
        value:          @state.value
        onChange:       @onChange
        onFocus:        @onFocus
        onBlur:         @onBlur
        onKeyUp:        @onKeyUp
      })
    )


#
#
cc.module('react/shared/input').exports = Component
