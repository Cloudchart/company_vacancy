# Imports
#
tag = React.DOM

Dispatcher = require('dispatcher/dispatcher')


components = []


# Functions
#
getComponents = ->
  { components: components }


# Main Component
#
Component = React.createClass


  onComponentsChange: ->
    @setState getComponents()


  componentDidMount: ->
  
  
  componentWillUnmount: ->
  
  
  getInitialState: ->
    getComponents()


  render: ->
    if @state.components.length == 0
      (tag.noscript null)
    else
      (tag.div {
        className: 'chart-modal-window'
      },
      
        # all but last windows

        # Overlay
        #
        (tag.div { className: 'overlay' })
          
        # last window
        @state.components[@state.components.length - 1].component
      )



# Dispatch
#
Component.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    
    # Show modal window
    #
    when 'blueprint:chart:modal:show'
      components.pop() if components.length > 0 and components[components.length - 1].options.key == action.options.key
      components.push({ component: action.component, options: action.options })
      
    
    
    # Close last modal window
    #
    when 'blueprint:chart:modal:hide'
      _.noop
    
    
    # Close all modal windows
    #
    when 'blueprint:chart:modal:close'
      _.noop


# Exports
#
module.exports = Component
