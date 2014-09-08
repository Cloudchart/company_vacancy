tag = React.DOM
email_re = /.+@.+\..+/i

# Main Component
#
Component = React.createClass

  # Component Specifications
  #
  render: ->
    (tag.div { className: 'profile-item' },
      (tag.div { className: 'content field' },
        (tag.input {
          value: @state.value
          placeholder: 'Type email'
          className: 'error' if @state.error
          onChange: @onChange
          onKeyUp: @onKeyUp
        })
      )

      (tag.div { className: 'actions' },
        (tag.button { 
          className: 'orgpad' 
          disabled: true if !@isValid() or @state.sync
        },
          (tag.span {}, 'Transfer ownership')
          (tag.i { className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-send-o' })
        )
      )
    )

  getInitialState: ->
    value: ''
    error: false
    sync: false

  # getDefaultProps: ->

  onChange: (event) ->
    @setState({ value: event.target.value })

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @transferOwnership() if @isValid()
      when 'Escape'
        console.log 'Escape'

  isValid: ->
    email_re.test(@state.value)

  transferOwnership: ->
    @setState({ sync: true, error: false })

    $.ajax
      url: @props.transfer_ownership_url
      type: 'POST'
      dataType: 'json'
      data:
        email: @state.value
    .done @onTransferOwnershipDone
    .fail @onTransferOwnershipFail

  onTransferOwnershipDone: ->
    @setState({ sync: false })
    console.log 'Done'

  onTransferOwnershipFail: ->
    @setState({ sync: false, error: true })
    console.warn 'Fail'

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
cc.module('react/company/transfer_ownership').exports = Component
