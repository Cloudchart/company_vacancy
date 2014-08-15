##= require components/editor/BlockIdentityController
##= require components/editor/IdentitySelector
##= require stores/BlockIdentityStore
##= require actions/BlockIdentityActionsCreator
##= require utils/BlockIdentitySyncAPI

# Expose
#
tag         = React.DOM

PersonModel = cc.models.Person

BlockIdentityControllerComponent  = cc.require('cc.components.Editor.BlockIdentityController')
IdentitySelectorComponent         = cc.require('cc.components.Editor.IdentitySelector')
BlockIdentityStore                = cc.require('cc.stores.BlockIdentityStore')
BlockIdentityActionsCreator       = cc.require('cc.actions.BlockIdentityActionsCreator')
BlockIdentitySyncAPI              = cc.require('cc.utils.BlockIdentitySyncAPI')


# Functions
#
getStateFromStores = (key) ->
  identities: BlockIdentityStore.allForBlock(key)


# People component
#
Component = React.createClass

  
  gatherIdentities: (event) ->
    _.chain(@state.identities)

      .sortBy (identity) -> identity.attr('position')

      .map (identity) ->
        (BlockIdentityControllerComponent { key: identity.to_param() })

      .value()
  
  
  onPersonSelect: (event) ->
    BlockIdentityActionsCreator.create
      block_id:       @props.key
      identity_type:  'Person'
      identity_id:    event.target.value
      position:       @state.identities.length
  
  
  onBlockIdentityStoreChange: ->
    @setState getStateFromStores(@props.key)


  componentDidMount: ->
    BlockIdentityStore.on('change', @onBlockIdentityStoreChange)
    
    unless @state.identitiesAreLoaded
      BlockIdentitySyncAPI.load(@props.url + '/identities')
  

  componentWillUnmount: ->
    BlockIdentityStore.on('change', @onBlockIdentityStoreChange)
  

  getInitialState: ->
    _.extend {}, getStateFromStores(@props.key),
      identitiesAreLoaded: !!@props.identitiesAreLoaded
  
  
  render: ->
    (tag.div { className: 'people' },
      @gatherIdentities()
      
      (IdentitySelectorComponent {
        key:                  @props.key
        identity_type:        @props.identity_type
        length:               @state.identities.length
        filtered_identities:  _.invoke(@state.identities, 'attr', 'identity_id')  
      })
      
      # (tag.div {
      #   key:        'selector'
      #   className:  'container'
      # },
      #   (cc.react.editor.blocks.IdentitySelector {
      #     placeholder:      'Type name'
      #     models:           { Person: @props.collection_url }
      #     filtered_models:  { Person: _.invoke(@state.identities, 'attr', 'identity_id') }
      #     onClick:          @onPersonSelect
      #   })
      # )
    )


# Expose
#
cc.react.editor.blocks.People = Component
