##= require actions/BlockIdentityActionsCreator
##= require components/Person
##= require components/Vacancy
##= require components/QueryInput
##= require stores/PersonStore
##= require stores/VacancyStore

# Imports
#
tag = React.DOM


BlockIdentityActionsCreator = cc.require('cc.actions.BlockIdentityActionsCreator')

PersonComponent     = cc.require('cc.components.Person')
VacancyComponent    = cc.require('cc.components.Vacancy')
QueryInputComponent = cc.require('cc.components.QueryInput')

PersonStore       = cc.require('cc.stores.PersonStore')
VacancyStore      = cc.require('cc.stores.VacancyStore')


IdentityStores =
  'Person':   PersonStore
  'Vacancy':  VacancyStore


IdentityComponents =
  'Person':   PersonComponent
  'Vacancy':  VacancyComponent


# Main Component
#
Component = React.createClass


  identityList: ->
    identityComponent = IdentityComponents[@props.identity_type]
    identityStore     = IdentityStores[@props.identity_type]

    identities = _.chain(identityStore.all())
      .reject (identity) => _.contains(@props.filtered_identities, identity.to_param())
      .filter (identity) => _.all @state.query, (q) -> identity.matches(q)
      .value()

    identities = identities.map (identity) =>
      (tag.li {
        key: identity.to_param()
        className: 'identity-list-item'
        onClick:  @onIdentitySelect.bind(@, identity.to_param())
      },
        (identityComponent { key: identity.to_param() })
      )
    
    (tag.ul {
      key:        'identity-list'
      className:  'identity-list'
    },
      identities
    )
  
  
  addButton: ->
    (tag.button {
      key:      'add-button'
      onClick:  @onAddButtonClick
    },
      "Add"
      (tag.i { className: 'fa fa-male' })
    )
  
  
  gatherControls: ->
    switch @state.mode
    
      when 'edit'
        [
          (QueryInputComponent {
            key:          'query-input'
            placeholder:  'Type name'
            autoFocus:    true
            onChange:     @onQueryChange
          })
          @identityList()
        ]
      
      when 'view'
        [
          @addButton()
        ]


  onAddButtonClick: ->
    @setState
      mode: 'edit'
  
  
  onQueryChange: (query) ->
    @setState
      query: query
  
  
  onIdentitySelect: (key) ->
    BlockIdentityActionsCreator.create
      block_id:       @props.key
      identity_type:  @props.identity_type
      identity_id:    key
      position:       @props.length

    @setState
      mode: 'view'


  getInitialState: ->
    mode:   'view'
    query:  []


  render: ->
    (tag.div { className: 'identity-selector aspect-ratio-1x1' },
      (tag.div {
        className:    'content'
      },
        @gatherControls()
      )
    )
    


# Exports
#
cc.module('cc.components.Editor.IdentitySelector').exports = Component
