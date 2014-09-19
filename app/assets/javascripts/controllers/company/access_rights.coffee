@['companies/access_rights#index'] = (data) ->
  
  CompanyStore  = require('stores/company_store')
  TokenStore    = require('stores/token')
  UsersStore    = require('stores/users')
  RolesStore    = require('stores/roles')

  #TokenSyncAPI    = require('sync/token_sync_api')
  
  CompanyActions  = require('actions/company')
  
  
  # Fetch data
  #
  promises = [
    CompanyActions.fetchAccessRights(data.company.uuid)
    CompanyActions.fetchInviteTokens(data.company.uuid)
  ]

  # Add loaded company
  #
  CompanyStore.add(data.company)
  
  # Access Rights component
  #
  AccessRightsComponent = require('components/company/access_rights')
  
  React.renderComponent(AccessRightsComponent({ key: data.company.uuid, roles: data.roles }), document.querySelector('[data-react-mount-point="access-rights"]'))
