# @cjsx React.DOM

GlobalState  = require('global_state/state')
UserStore    = require('stores/user_store.cursor')

ModalStack   = require('components/modal_stack')

Tour         = require('components/tour/welcome/app')


# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourApp'

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