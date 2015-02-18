# @cjsx React.DOM


# Stores
#
PinStore = require('stores/pin_store')


# Components
#
PinnableComponents =
  'Post': require('components/pinnable/post')


# Exports
#
module.exports = React.createClass

  displayName: 'PinnablePreview'


  render: ->
    pin       = PinStore.cursor.items.get(@props.uuid)
    component = PinnableComponents[pin.get('pinnable_type')]

    component({ uuid: pin.get('pinnable_id'), pin: pin })
