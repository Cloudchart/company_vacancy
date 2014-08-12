tag = React.DOM

Component = React.createClass

  render: ->
    (tag.div { className: 'field' },
      (tag.label { htmlFor: 'short_name' }, 'Short Name')

      (tag.div { className: 'input-wrapper'},
        (tag.input {
          id: 'short_name'
          name: 'short_name'
          placeholder: 'Type name'
          onKeyUp: @onKeyUp
          onChange: @onChange
          onBlur: @onBlur
          value: @state.value
        })

        (tag.button {
          className: 'red' if @state.error
          # onClick: @onClick
          disabled: true
        },
          (tag.i { 
            className: 
              if @state.sync
                'fa fa-spinner fa-spin'
              else if @state.error
                'fa fa-times'
              else if @state.success
                'fa fa-check'
              else
                'fa fa-pencil'
          })
        )

      )

    )

  getInitialState: ->
    value: @props.value
    sync: false
    error: false
    success: false

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
      success: true

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

  onBlur: ->
    @undoTyping()

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @save() unless @props.value == @state.value
      when 'Escape'
        @undoTyping()

  # onClick: (event) ->
  #   @updateValue()

  onChange: (event) ->
    @setState
      value: event.target.value

# Exports
#
cc.module('react/company/short_name').exports = Component
