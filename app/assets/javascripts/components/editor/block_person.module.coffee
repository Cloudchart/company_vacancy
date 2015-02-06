# @cjsx React.DOM

# Imports
#
CloudFlux     = require('cloud_flux')


BlockActions  = require('actions/block_actions')

BlockStore    = require('stores/block_store')

Person        = require('components/editor/person')


# Main
#
Component = React.createClass

  # Component specifications
  #
  propTypes:
    company_id:  React.PropTypes.string.isRequired
    readOnly:    React.PropTypes.bool
    uuid:        React.PropTypes.string.isRequired

  getDefaultProps: ->
    readOnly: false
  
  getInitialState: ->
    @getStateFromStores()

  getStateFromStores: ->
    identityIdsSeq: Immutable.Seq(BlockStore.get(@props.uuid).identity_ids)
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())


  mixins: [CloudFlux.mixins.Actions]

  statics:
    isEmpty: (block_id) ->
      BlockStore.get(block_id).identity_ids.size == 0

  # Handlers
  #
  handleAdd: (key) ->
    return if @props.readOnly

    identity_ids = @state.identityIdsSeq.toList().push(key)

    BlockActions.update(@props.uuid, { identity_ids: identity_ids.toArray() })

  handleDelete: (uuid) ->
    return if @props.readOnly

    identity_ids = @state.identityIdsSeq.toList().remove(@state.identityIdsSeq.indexOf(uuid))

    BlockActions.update(@props.uuid, { identity_ids: identity_ids.toArray() })


  # Lifecycle methods
  #
  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)

  componentWillReceiveProps: ->
    @refreshStateFromStores()


  render: ->
    <Person 
      company_id  = { @props.company_id }
      onAdd       = { @handleAdd }
      onDelete    = { @handleDelete }
      readOnly    = { @props.readOnly }
      selected    = { @state.identityIdsSeq }
    />


# Exports
#
module.exports = Component
