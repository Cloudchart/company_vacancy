# @cjsx React.DOM

GlobalState  = require('global_state/state')
UserStore    = require('stores/user_store.cursor')

ModalStack   = require('components/modal_stack')

Tour         = require('components/tour/app')


# Exports
#
module.exports = React.createClass

  displayName: 'TourApp'

  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor: UserStore.me()


  openTour: ->
    return null unless @props.cursor.deref(false)

    ModalStack.show(
      <Tour />
    )


  # Lifecycle methods
  #
  componentDidMount: ->
    @openTour()
    
  componentWillUpdate: ->
    @openTour()


  # Renderers
  #
  render: ->
    null