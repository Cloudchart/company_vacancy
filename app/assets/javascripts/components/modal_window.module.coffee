# Imports
#
tag = React.DOM

CloudFlux = require('cloud_flux')


# Main
#
Component = React.createClass


  mixins: [CloudFlux.mixins.Actions]


  _deprecated_show: (event) ->
    console.warn "Deprecation: use ModalActions.show instead of Event triggering."
    @show(event.detail.component)


  _deprecated_hide: ->
    console.warn "Deprecation: use ModalActions.hide instead of Event triggering."
    @hide()


  _deprecated_close: ->
    console.warn "Deprecation: use ModalActions.close instead of Event triggering."
    @close()
    
    
  show: (component) ->
    @setState({ components: @state.components.push(component) })
  
  
  hide: ->
    @setState({ components: @state.components.pop() })
  
  
  close: ->
    @setState(@getInitialState())


  componentDidMount: ->
    # Deprecated
    window.addEventListener 'modal:push',   @_deprecated_show
    window.addEventListener 'modal:pop',    @_deprecated_hide
    window.addEventListener 'modal:close',  @_deprecated_close
  
  
  componentWillUnmount: ->
    # Deprecated
    window.removeEventListener 'modal:push',  @_deprecated_show
    window.removeEventListener 'modal:pop',   @_deprecated_hide
    window.removeEventListener 'modal:close', @_deprecated_close
  
  
  onOverlayClick: (event) ->
    @close() if event.target == @refs['overlay'].getDOMNode()
    
  
  
  getCloudFluxActions: ->
    'modal:show':   @show
    'modal:hide':   @hide
    'modal:close':  @close


  getInitialState: ->
    components:       new Immutable.Vector


  render: ->
    if @state.components.count() == 0
      (tag.noscript null)
    else
      (tag.div {
        ref:        'overlay'
        className:  'modal-overlay'
        onClick:    @onOverlayClick
      },
        (tag.div {
          className: 'modal-container'
        },
          @state.components.last()
        )
      )


# Exports
#
module.exports = Component
