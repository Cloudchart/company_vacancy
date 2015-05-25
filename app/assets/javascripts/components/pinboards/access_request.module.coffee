# @cjsx React.DOM

ModalStack        = require('components/modal_stack')

RoleAccessRequest = require('components/roles/access_request')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardAccessRequestTrigger'

  propTypes:
    uuid:  React.PropTypes.string.isRequired

  showCollections: ->
    location.pathname = '/collections'

  openRequest: ->
    ModalStack.show(
      <RoleAccessRequest
        ownerId    = { @props.uuid }
        ownerType  = 'Pinboard' />
      ,
      beforeHide: @showCollections
    )


  # Lifecycle methods
  #
  componentDidMount: ->
    @openRequest()


  # Renderers
  #
  render: ->
    null