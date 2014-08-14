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

      if @state.is_url_verified
        (tag.i { className: 'fa fa-check-circle' })
      else
        (tag.button {
          className: "orgpad#{if @state.can_delete then ' alert' else ''}"
          disabled: true if @state.is_url_verified or !@state.can_delete and !@isValid() or @state.sync
          onClick: @save
        },
          if @state.verification_sent
            [
              (tag.span { key: 'button_value' }, 'Resend')
              (tag.i { 
                key: 'button_icon'
                className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-envelope-o'
              })
            ]
          else if @state.can_delete
            [
              (tag.span { key: 'button_value' }, 'Delete')
              (tag.i { 
                key: 'button_icon' 
                className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-times'
              })
            ]
          else 
            [
              (tag.span { key: 'button_value' }, 'Verify')
              (tag.i { 
                key: 'button_icon'
                className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-envelope-o'
              })
            ]
        )

    )

  getInitialState: ->
    value: @props.value
    verification_sent: @props.verification_sent
    is_url_verified: @props.is_url_verified
    sync: false
    error: false
    can_delete: false

  # getDefaultProps: ->

  onChange: (event) ->
    @setState({ value: event.target.value })

  onKeyUp: (event) ->
    @setState
      verification_sent: 
        if @props.value == @state.value and @state.value != ''
          true
        else
          false
      is_url_verified: 
        if @props.is_url_verified and @props.value == @state.value and @state.value != ''
          true
        else 
          false
      can_delete: 
        if @state.value == '' and @props.value != @state.value 
          true 
        else
          false

    switch event.key
      when 'Enter'
        @save() if @isValid() or @state.value == '' and @props.value != @state.value
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
      contentType: false
      processData: false

    .done @onSaveDone
    .fail @onSaveFail

  onSaveDone: (json) ->
    @setState
      sync: false
      verification_sent: if @state.value == '' then false else true
      is_url_verified: false
      can_delete: false

    @props.onChange(
      target:
        value: @state.value
        verification_sent: @state.verification_sent
        is_url_verified: @state.is_url_verified
    )
  
  onSaveFail: ->
    @setState
      sync: false
      error: true

  undo: ->
    @setState
      value: @props.value
      verification_sent: @props.verification_sent
      is_url_verified: @props.is_url_verified unless @props.value == ''
      can_delete: false

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
