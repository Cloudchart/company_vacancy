# Expose
#
tag = React.DOM


# Main component
#
MainComponent = React.createClass


  filterIdentities: (identities) ->
    @setState { identities: identities }
  
  
  filteredIdentities: ->
    identities = _.extend {}, @state.identities

    _.each @props.filtered_models, (uuids, model_class_name) ->
      if identities[model_class_name]
        identities[model_class_name] = _.reject identities[model_class_name], (uuid) -> _.contains(uuids, uuid)

    identities
  
  
  onMouseDown: (event) ->
    event.preventDefault() if @refs.search.state.active
  
  
  onPersonClick: (event) ->
    @props.onClick(event) if @props.onClick instanceof Function
    @refs.search.blur()
  
  
  getInitialState: ->
    identities: {}


  render: ->
    (tag.div {
      className:    'identity-selector'
      onMouseDown:  @onMouseDown
    },
      (cc.react.shared.IdentitySearch {
        ref:          'search'
        placeholder:  @props.placeholder
        models:       @props.models
        onSearch:     @filterIdentities
      })

      (cc.react.shared.IdentityList {
        onClick:    @onPersonClick
        identities: @filteredIdentities()
      })
    )


# Expose
#
cc.react.editor.blocks.IdentitySelector = MainComponent
