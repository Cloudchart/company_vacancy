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

      (tag.button {
        className: 'orgpad'
        disabled: true unless @isValid()
        onClick: @save
      }, 
        'Go'
        (tag.i { className: 'fa fa-envelope-o' })
        # (tag.i { className: 'fa fa-cloud-download' })
      )

      # (tag.a { href: '#' },
      #   (tag.i { className: 'fa fa-envelope' })
      # )

    )

  getInitialState: ->
    value: @props.value
    error: false
    sync: false

  # getDefaultProps: ->

  onChange: (event) ->
    @setState({ value: event.target.value })

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @save() if @isValid()
      when 'Escape'
        console.log 'Escape'
        # @undoTyping()

  isValid: ->
    regex.test(@state.value)

  save: ->
    unless @props.value == @state.value

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
    @setState({ sync: false })
    @props.onChange({ target: { value: @state.value } })
  
  onSaveFail: ->
    @setState
      sync: false
      error: true

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
