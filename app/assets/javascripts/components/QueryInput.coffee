###
  Used in:

  components/editor/IdentitySelector
###

# Imports
#
tag = React.DOM


# Functions
#
prepareQuery = (query) ->
  query = '' unless _.isString(query)
  parts = _(query.split(/\s+/)).filter((part) -> part.length).invoke('toLowerCase').value()


# Main Component
#
Component = React.createClass


  cancel: ->
    @blur()
    @props.onCancel() if _.isFunction(@props.onCancel)


  blur: ->
    @refs['query-input'].getDOMNode().blur()


  onChange: (event) ->
    @setState({ query: event.target.value, source: 'self' })
  
  
  onKeyUp:  (event) ->
    
    switch event.key
    
      when 'Escape'
        @cancel() if @state.query == ''
        @setState({ query: '', source: 'self' })
  
  
  onFocus: (event) ->
  
  
  onBlur: (event) ->
  
  
  componentWillReceiveProps: ->
    @setState({ source: 'parent' })
  
  
  componentDidUpdate: ->
    if @state.source == 'self'
      @props.onChange(prepareQuery(@state.query)) if _.isFunction(@props.onChange)
  
  
  getInitialState: ->
    query: ''


  render: ->
    @transferPropsTo(
      (tag.input {
        ref:            'query-input'
        value:          @state.query
        autoComplete:   false
        onChange:       @onChange
        onKeyUp:        @onKeyUp
        onFocus:        @onFocus
        onBlur:         @onBlur
      })
    )


# Exports
#
cc.module('cc.components.QueryInput').exports = Component
