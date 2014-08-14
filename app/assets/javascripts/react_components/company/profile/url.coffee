tag = React.DOM
regex = /(.+)\.(.+)/

# Main Component
#
Component = React.createClass

  # Component Specifications
  #
  render: ->
    (tag.div { className: 'field' },   
      (tag.label { htmlFor: 'url' }, 'Site URL')

      (tag.input {
        id: 'url'
        name: 'url'
        value: @state.value
        placeholder: 'Type URL'
        onChange: @onChange
        onKeyUp: @onKeyUp
        # onBlur: @onBlur
      })

      (tag.div {},
        (tag.button {
          className: 'orgpad'
          disabled: true if !@isValid() or @state.is_url_verified
          onClick: @save
        },
          unless @state.is_url_verified
            if @state.verification_sent 
              'Resend' 
            else 
              'Verify'

          (tag.i { className: if @state.is_url_verified then 'fa fa-check' else 'fa fa-envelope-o' })
        )
      )

    )

  getInitialState: ->
    value: @props.value
    sync: false
    error: false
    verification_sent: @props.verification_sent
    is_url_verified: @props.is_url_verified

  # getDefaultProps: ->

  onChange: (event) ->
    @setState({ value: event.target.value })

  onKeyUp: (event) ->
    @setState
      verification_sent: if @props.value == @state.value and @state.value != '' then true else false
      is_url_verified: if @props.is_url_verified and @props.value == @state.value then true else false

    switch event.key
      when 'Enter'
        @save() if @isValid()
      when 'Escape'
        @undo()

  # onBlur: ->
  #   @undo()

  isValid: ->
    regex.test(@state.value)

  save: ->
    # unless @props.value == @state.value

    data = new FormData
    data.append('company[url]', @state.value)

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
      verification_sent: true
      is_url_verified: false

    @props.onChange({ target: { value: @state.value, verification_sent: @state.verification_sent } })
  
  onSaveFail: ->
    @setState
      sync: false
      error: true

  undo: ->
    @setState
      value: @props.value
      verification_sent: @props.verification_sent
      is_url_verified: @props.is_url_verified

  # Lifecycle Methods
  #
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

# Exports
#
cc.module('react/company/url').exports = Component
