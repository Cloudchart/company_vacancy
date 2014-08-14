tag = React.DOM

Component = React.createClass

  render: ->
    (tag.div { className: 'field' },
      (tag.label { htmlFor: 'short_name' }, 'Short Name')

      (tag.input {
        id: 'short_name'
        name: 'short_name'
        value: @state.value
        placeholder: 'Type name'
        className: 'error' if @state.error
        onKeyUp: @onKeyUp
        onChange: @onChange
      })

      if @state.success
        (tag.i { className: 'fa fa-check-circle' })
      else
        (tag.button {
          className: 'orgpad'
          onClick: @onClick
          disabled: true if @state.sync or @state.value == '' and @state.value == @props.value
        },
          (tag.span {}, 'Edit') 
          (tag.i { 
            className: 
              if @state.sync
                'fa fa-spinner fa-spin'
              else
                'fa fa-pencil' 
          })
        )

    )

  getInitialState: ->
    value: @props.value
    sync: false
    error: false
    success: 
      if @props.value == '' or @props.value == null 
        false
      else
        true

  # componentWillReceiveProps: (nextProps) ->
  # componentDidUpdate: (prevProps, prevState) ->

  save: ->
    data = new FormData
    data.append('company[short_name]', @state.value)

    @setState({ sync: true, error: false })

    $.ajax
      url: @props.company_url
      data: data
      type: 'PUT'
      dataType: 'json'
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail

  onSaveDone: (json) ->
    @setState
      sync: false
      success: if @state.value != '' then true else false

    @props.onChange({ target: { value: @state.value } })
  
  onSaveFail: ->
    @setState
      sync: false
      error: true    

  undoTyping: ->
    @setState
      value: @props.value
      error: false
      success: false

  onKeyUp: (event) ->
    @setState
      success: if @state.value == @props.value and @state.value != '' then true else false

    switch event.key
      when 'Enter'
        @save() unless @props.value == @state.value
      when 'Escape'
        @undoTyping()

  onClick: (event) ->
    @save() unless @props.value == @state.value

  onChange: (event) ->
    @setState
      value: event.target.value

# Exports
#
cc.module('react/company/short_name').exports = Component
