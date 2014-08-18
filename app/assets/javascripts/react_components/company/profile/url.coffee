tag = React.DOM
regex = /(.+)\.(.+)/

# CancelVerificationComponent
# 
CancelVerificationComponent = React.createClass
  
  render: ->
    (tag.button {
      className: 'orgpad alert'
      disabled: true if @state.sync
      onClick: @save
    },
      (tag.span {}, 'Cancel')
      (tag.i { 
        className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-eraser'
      })
    )

  getInitialState: ->
    value: ''
    sync: false
    error: false
    verification_sent: false

  # onCancelClick: ->
    # console.log 'click'

  # onChange: (event) ->
    # @setState({ value: event.target.value })

  save: ->
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

    @props.onChange(
      target:
        value: @state.value
        verification_sent: @state.verification_sent
    )
  
  onSaveFail: ->
    @setState
      sync: false
      error: true

# MainComponent
#
MainComponent = React.createClass

  # Component Specifications
  #
  render: ->
      if @state.verification_sent
        (tag.div { className: 'profile-item' },

          (tag.div { className: 'content' },
            "Download this file and make it accessible from the root directory of your domain www.ludikakludi.com"
          )

          (tag.div { className: 'actions' },
            (tag.button {
              className: 'orgpad'
              disabled: true if @state.sync
              # onClick: @save
            },
              (tag.span {}, 'Check file')
              (tag.i { 
                className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-file-text-o'
              })
            )

            (CancelVerificationComponent {
              value: @state.value
              company_url: @props.company_url
              onChange: @onCancelButtonChange
            })          
          )
        )
      else
        (tag.div { className: 'profile-item' },
          (tag.div { className: 'content field' },
            (tag.label { htmlFor: 'url' }, 'Site URL')

            (tag.input {
              id: 'url'
              name: 'url'
              value: @state.value
              placeholder: 'Type URL'
              className: 'error' if @state.error
              onChange: @onChange
              onKeyUp: @onKeyUp
              # onBlur: @onBlur
            })
          )

          (tag.button {
            className: 'orgpad'
            disabled: true if !@isValid() or @state.sync
            onClick: @save
          },
            (tag.span {}, 'Verify')
            (tag.i { 
              className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-envelope-o'
            })
          )
        )

      # if @state.is_url_verified
      #   (tag.i { className: 'fa fa-check-circle' })
      # else
      #   (tag.button {
      #     className: "orgpad#{if @state.can_delete then ' alert' else ''}"
      #     disabled: true if @state.is_url_verified or !@state.can_delete and !@isValid() or @state.sync
      #     onClick: @save
      #   },
      #     if @state.verification_sent
      #       [
      #         (tag.span { key: 'button_value' }, 'Resend')
      #         (tag.i { 
      #           key: 'button_icon'
      #           className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-envelope-o'
      #         })
      #       ]
      #     else if @state.can_delete
      #       [
      #         (tag.span { key: 'button_value' }, 'Delete')
      #         (tag.i { 
      #           key: 'button_icon' 
      #           className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-times'
      #         })
      #       ]
      #     else 
      #       [
      #         (tag.span { key: 'button_value' }, 'Verify')
      #         (tag.i { 
      #           key: 'button_icon'
      #           className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-envelope-o'
      #         })
      #       ]
      #   )

    # )

  getInitialState: ->
    value: @props.value
    verification_sent: @props.verification_sent
    is_url_verified: @props.is_url_verified
    sync: false
    error: false
    can_delete: false

  # getDefaultProps: ->

  onCancelButtonChange: (event) ->
    @setState(
      value: event.target.value 
      verification_sent: event.target.verification_sent
    )

  onChange: (event) ->
    @setState({ value: event.target.value })

  onKeyUp: (event) ->
    # @setState
    #   verification_sent: 
    #     if @props.value == @state.value and @state.value != ''
    #       true
    #     else
    #       false
    #   is_url_verified: 
    #     if @props.is_url_verified and @props.value == @state.value and @state.value != ''
    #       true
    #     else 
    #       false
    #   can_delete: 
    #     if @state.value == '' and @props.value != @state.value 
    #       true 
    #     else
    #       false

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
      contentType: false
      processData: false

    .done @onSaveDone
    .fail @onSaveFail

  onSaveDone: (json) ->
    @setState
      sync: false
      verification_sent: true
      is_url_verified: false
      can_delete: false

    @props.onChange(
      target:
        value: @state.value
        # verification_sent: @state.verification_sent
        is_url_verified: @state.is_url_verified
    )
  
  onSaveFail: ->
    @setState
      sync: false
      error: true

  undo: ->
    @setState
      value: ''
      error: false
      # verification_sent: @props.verification_sent
      # is_url_verified: @props.is_url_verified unless @props.value == ''
      # can_delete: false

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
cc.module('react/company/url').exports = MainComponent
