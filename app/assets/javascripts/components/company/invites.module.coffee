# Imports
#
tag = React.DOM

CompanyStore            = require('stores/company_store')
TokenStore              = require('stores/token_store')
TokenActions            = require('actions/token_actions')
InvitationFormComponent = require('components/company/invitation_form')


# Get State from Stores
#
getStateFromStores = (key) ->
  company:  CompanyStore.get(key)
  tokens:   TokenStore.filter (item) -> item.get('owner_id') == key and item.get('name') == 'invite'


# Main
#
Component = React.createClass


  gatherTokens: ->
    _.map @state.tokens, (token_props) =>
      isDeleted = _.contains(@state.deletedItems, token_props.uuid)
      
      (tag.tr {
        key: token_props.uuid
      },
      
        (tag.td {}, token_props.data.email)
        (tag.td {}, token_props.data.role)
        (tag.td {},
          (tag.button {
            onClick:    @onCancelButtonClick.bind(@, token_props.uuid)
            disabled:   isDeleted
          },
            'Cancel'
            if isDeleted
              (tag.i { className: 'fa fa-spinner fa-spin' })
            else
              (tag.i { className: 'fa fa-times' })
          )
        )
      
      )
  
  
  onCancelButtonClick: (key, event) ->
    deletedItems = @state.deletedItems || []
    deletedItems.push(key)
    @setState({ deletedItems: deletedItems })
    TokenActions.deleteCompanyInvite(key, @props.key)


  refreshStateFromStores: ->
    @setState getStateFromStores(@props.key)


  componentDidMount: ->
    TokenStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    TokenStore.off('change', @refreshStateFromStores)


  getInitialState: ->
    state = getStateFromStores(@props.key)
    state


  render: ->
    (tag.div {
    },
    
      # Current invites
      #
      (tag.table {
        style:
          border: '1px solid #ccc'
      },
        (tag.thead {
        },
          (tag.tr {
          },
            (tag.td {}, 'User')
            (tag.td {}, 'Role')
            (tag.td {}, 'Action')
          )
        )
        (tag.tbody {
        },
          @gatherTokens()
        )
      )
      
      (InvitationFormComponent { key: TokenStore.create(), company: @state.company })
      
      # Invite user button
      #
      (tag.button {
      },
        'Invite user'
        (tag.i { className: 'fa fa-plus' })
      )
    )


# Exports
#
module.exports = Component
