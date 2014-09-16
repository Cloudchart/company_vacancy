# Imports
#
tag = React.DOM

CompanyStore            = require('stores/company_store')
TokenStore              = require('stores/token_store')
InvitationFormComponent = require('components/company/invitation_form')


# Get State from Stores
#
getStateFromStores = (key) ->
  company: CompanyStore.get(key)


# Main
#
Component = React.createClass


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
      )
      
      (InvitationFormComponent { key: TokenStore.create(), company: @state.company })
      
      # Invite user button
      #
      (tag.button {
      }, 'Invite user')
    )


# Exports
#
module.exports = Component
