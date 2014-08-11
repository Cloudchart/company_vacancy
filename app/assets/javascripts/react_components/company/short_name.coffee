tag = React.DOM

Component = React.createClass

  render: ->
    (tag.div { className: 'fields' },
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
          className: 'red' if @props.error
          # onClick: @onClick
          disabled: true
        },
          (tag.i { 
            className: 
              if @props.sync
                'fa fa-spinner fa-spin'
              else if @props.error
                'fa fa-times'
              else if @props.success
                'fa fa-check'
              else
                'fa fa-pencil'
          })
        )

      )

    )

  getInitialState: ->
    value: @props.value

  # componentWillReceiveProps: (nextProps) ->
  #   @setState({  })

  updateValue: ->
    @props.onChange({ target: { value: @state.value } })

  undoTyping: ->
    @setState({ value: @props.value })

  onBlur: ->
    @undoTyping()

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @updateValue()
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
