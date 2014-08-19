tag = React.DOM

# RemoveShortNameComponent
# 
RemoveShortNameComponent = React.createClass

  render: ->
    (tag.button { 
      className: 'orgpad alert' 
      onClick: @save
      disabled: true if @state.sync
    },
      (tag.span {}, 'Remove')
      (tag.i { 
        className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-eraser' 
      })
    )

  getInitialState: ->
    sync: false
    error: false

  save: ->    
    data = new FormData
    data.append('company[short_name]', '')

    @setState({ sync: true })

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
    url = window.location.href
    parts = url.split('/')
    parts.pop()
    parts.push(@props.company_uuid)
    window.location.href = parts.join('/')

  onSaveFail: ->
    console.warn 'RemoveShortNameComponent fail'

# Main Component
# 
Component = React.createClass

  render: ->
    if @state.is_short_name_valid
      (tag.div { className: 'profile-item' },
        (tag.div { className: 'content field' },
          (tag.span { className: 'label' }, 'Short URL')
          (tag.span {}, 'cloudchart.co/companies/')
          (tag.span {}, @state.value)
        )

        (tag.div { className: 'actions' },
          (RemoveShortNameComponent {
            company_uuid: @props.company_uuid
          })
        )
      )
    else
      (tag.div { className: 'profile-item' },
        (tag.div { className: 'content field' },
          (tag.label { htmlFor: 'short_name' }, 'Short URL')
          (tag.div { className: 'spacer' })
          (tag.span {}, @props.default_host + '/companies/')

          (tag.input {
            id: 'short_name'
            name: 'short_name'
            value: @state.value
            placeholder: 'Type name'
            className: 'error' if @state.error
            onKeyUp: @onKeyUp
            onChange: @onChange
          })
        )

        (tag.div { className: 'actions' },
          (tag.button {
            className: 'orgpad'
            onClick: @onClick
            disabled: true if @state.sync or @state.value == '' or @state.value == null
          },
            (tag.span {}, 'Save') 
            (tag.i { 
              className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-save'
            })
          )
        )
      )

  getInitialState: ->
    value: @props.value
    sync: false
    error: false
    is_short_name_valid: 
      if @props.value == '' or @props.value == null 
        false
      else
        true

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
    url = window.location.href
    parts = url.split('/')
    parts.pop()
    parts.push(@state.value)
    window.location.href = parts.join('/')

  onSaveFail: ->
    @setState
      sync: false
      error: true

  undoTyping: ->
    @setState
      value: ''
      error: false

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @save() unless @props.value == @state.value
      when 'Escape'
        @undoTyping()

  onClick: (event) ->
    @save() unless @props.value == @state.value

  onChange: (event) ->
    @setState({ value: event.target.value })

# Exports
#
cc.module('react/company/short_name').exports = Component
