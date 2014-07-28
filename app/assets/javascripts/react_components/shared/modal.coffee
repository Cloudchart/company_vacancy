#
#
tag = React.DOM


# Main
#
Component = React.createClass


  push: (event) ->
    components = @state.components[0..]
    components.push(event.detail.component)
    @setState({ components: components })
  
  
  pop: (event) ->
    components = @state.components[0..]
    components.pop()
    @setState({ components: components })


  close: ->
    @setState({ components: [] })
  
  
  preventClose: (event) ->
    event.stopPropagation()


  componentDidMount: ->
    window.addEventListener('modal:close',  @close)
    window.addEventListener('modal:push',   @push)
    window.addEventListener('modal:pop',    @pop)
  
  
  componentWillUnmount: ->
    window.removeEventListener('modal:close',   @close)
    window.removeEventListener('modal:push',    @push)
    window.removeEventListener('modal:pop',     @pop)
  
  
  componentDidUpdate: ->


  getDefaultProps: ->
    components: []


  getInitialState: ->
    components: @props.components


  render: ->
    if @state.components.length == 0
      (tag.noscript {})
    else
      (tag.div {
        className:  'modal-overlay'
        onClick:    @close
      },
        (tag.div {
          className:  'modal-container'
          onClick:    @preventClose
        },
          @state.components[@state.components.length - 1]
        )
      )


# Exports
#
cc.module('react/shared/modal').exports = Component
