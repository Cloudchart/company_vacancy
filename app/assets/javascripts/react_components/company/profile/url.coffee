tag = React.DOM
regex = /(.+)\.(.+)/

# CheckFileComponent
# 
CheckFileComponent = React.createClass
  render: ->
    (tag.button {
      className: 'orgpad'
      disabled: true if @state.sync
      onClick: @checkFile
    },
      (tag.span {}, 'Check file')
      (tag.i { 
        className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-file-text-o'
      })
    )

  getInitialState: ->
    sync: false

  checkFile: ->
    @setState({ sync: true })

    $.ajax
      url: @props.verify_url
      type: 'GET'
      dataType: 'json'

    .done @onCheckFileDone
    .fail @onCheckFileFail

  onCheckFileDone: (json) ->
    @setState({ sync: false })

    if json == 'ok'
      is_url_verified = true
      url_verification_failed = false
    else
      is_url_verified = false
      url_verification_failed = true

    @props.onChange(
      target:
        is_url_verified: is_url_verified
        url_verification_failed: url_verification_failed
    )

  onCheckFileFail: (json) ->
    @setState({ sync: false })
    console.warn 'checkFile fail'

# CancelVerificationComponent
# 
CancelVerificationComponent = React.createClass
  
  render: ->
    (tag.button {
      className: 'orgpad alert'
      disabled: true if @state.sync
      onClick: @save
    },
      (tag.span {}, @props.button_value)
      (tag.i { 
        className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-eraser'
      })
    )

  getInitialState: ->
    value: ''
    sync: false

  save: ->
    data = new FormData
    data.append('company[url]', @state.value)

    @setState({ sync: true })

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
    @setState({ sync: false })

    @props.onChange(
      target:
        value: @state.value
        verification_sent: false
        is_url_verified: false
        url_verification_failed: false
    )
  
  onSaveFail: ->
    @setState({ sync: false })
    console.warn 'CancelVerificationComponent save fail'

# MainComponent
#
MainComponent = React.createClass

  # Component Specifications
  #
  render: ->
      if @state.is_url_verified
        (tag.div { className: 'profile-item' },
          (tag.div { className: 'content field' },
            (tag.span {}, 'Site URL')
            @formattedSiteLink(@state.value)
            (tag.i { className: 'fa fa-check-circle' })
          )

          (tag.div { className: 'actions' },
            (CancelVerificationComponent {
              company_url: @props.company_url
              onChange: @onCancelButtonChange
              button_value: 'Remove'
            })
          )
        )
      else if @state.verification_sent
        (tag.div { className: 'profile-item' },

          (tag.div { className: 'content paragraph' },
            (tag.strong {}, 'File not found. ') if @state.url_verification_failed
            (tag.a { href: @props.download_verification_file_url }, 'Download this file')
            (tag.span {}, ' and make it accessible from the root directory of your domain ')
            @formattedSiteLink(@state.value)
          )

          (tag.div { className: 'actions' },
            (CheckFileComponent {
              verify_url: @props.verify_url
              onChange: @onCheckFileChange
            })

            (CancelVerificationComponent {
              company_url: @props.company_url
              onChange: @onCancelButtonChange
              button_value: 'Cancel'
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

  getInitialState: ->
    value: @props.value
    verification_sent: @props.verification_sent
    is_url_verified: @props.is_url_verified
    url_verification_failed: @props.url_verification_failed
    sync: false
    error: false
    verification_sent:
      if @props.value == null or @props.value == '' then false else true

  # getDefaultProps: ->

  formattedSiteLink: (value) ->
    if /http:\/\/|https:\/\//.test(value)
      formatted_site_url = value
    else
      formatted_site_url = 'http://' + value

    (tag.a { href: formatted_site_url, target: '_blank' }, value)

  onChange: (event) ->
    @setState({ value: event.target.value })

  onCancelButtonChange: (event) ->
    @setState
      value: event.target.value 
      verification_sent: event.target.verification_sent
      is_url_verified: event.target.is_url_verified
      url_verification_failed: event.url_verification_failed

  onCheckFileChange: (event) ->
    @setState
      is_url_verified: event.target.is_url_verified
      url_verification_failed: event.target.url_verification_failed

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @save() if @isValid()
      when 'Escape'
        @undo()

  isValid: ->
    regex.test(@state.value)

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
      verification_sent: true
      is_url_verified: false
  
  onSaveFail: ->
    @setState
      sync: false
      error: true

  undo: ->
    @setState
      value: ''
      error: false

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
