# @cjsx React.DOM

# Imports
#
CloudFlux     = require('cloud_flux')


BlockActions  = require('actions/block_actions')

BlockStore    = require('stores/block_store')

PersonList    = require('components/editor/person_list')


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
    @getStateFromStores(@props)

  getStateFromStores: (props) ->
    identityIdsSeq: Immutable.Seq(BlockStore.get(props.uuid).identity_ids)
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  mixins: [CloudFlux.mixins.Actions]

  statics:
    isEmpty: (block_id) ->
      BlockStore.get(block_id).identity_ids.size == 0

  # Handlers
  #
  handleAdd: (uuid) ->
    return if @props.readOnly

    identity_ids = @state.identityIdsSeq.toList().push(uuid)

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

  componentWillReceiveProps: (nextProps) ->
    @setState @getStateFromStores(nextProps)


  render: ->
    <PersonList 
      company_id  = { @props.company_id }
      onAdd       = { @handleAdd }
      onDelete    = { @handleDelete }
      readOnly    = { @props.readOnly }
      selected    = { @state.identityIdsSeq }
    />


# Exports
#
module.exports = Component
