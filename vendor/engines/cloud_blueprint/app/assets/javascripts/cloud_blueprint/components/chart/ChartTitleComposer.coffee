##= require ../../stores/ChartStore
##= require ../../actions/ChartActionsCreator

# Imports
#
tag = React.DOM


ChartStore          = cc.require('cc.blueprint.stores.ChartStore')
ChartActionsCreator = cc.require('cc.blueprint.actions.ChartActionsCreator')


# Get State From Store
#
getStateFromStore = (key) ->
  chart = ChartStore.get(key) || {}
  
  chart:      chart
  title:      chart.title || ''
  prevTitle:  chart.title || ''
  slug:  chart.slug


# Component
#
Component = React.createClass


  blur: ->
    @getDOMNode().blur()


  onTitleChange: (event) ->
    @setState
      title: event.target.value
  
  
  onKeyDown: (event) ->
    switch event.key

      when 'Enter'
        @blur()

      when 'Escape'
        @setState
          title: @state.prevTitle
  
  
  onBlur: (event) ->
    ChartActionsCreator.update(@props.key, { title: @state.title }, true)

  
  onChartStoreChange: ->
    @setState getStateFromStore(@props.key)


  componentDidMount: ->
    ChartStore.on('change', @onChartStoreChange)
  
  
  componentWillUnmount: ->
    ChartStore.off('change', @onChartStoreChange)


  # TODO move to controller
  componentDidUpdate: (prevProps, prevState) ->
    if @state.slug isnt prevState.slug
      url = window.location.href
      parts = url.split('/')
      parts.pop()
      parts.push(@state.slug)
      window.location.href = parts.join('/')


  getInitialState: ->
    getStateFromStore(@props.key)


  render: ->
    (tag.input {
      autoComplete: 'off'
      value:        @state.title
      onChange:     @onTitleChange
      onKeyDown:    @onKeyDown
      onBlur:       @onBlur
      disabled:     @state.chart.isSynchronizing
    })


# Exports
#
cc.module('cc.blueprint.components.chart.ChartTitleComposer').exports = Component
