@['companies/access_rights#index'] = (data) ->
  
  CompanyStore  = require('stores/company_store')
  TokenStore    = require('stores/token_store')
  TokenSyncAPI  = require('sync/token_sync_api')
  
  
  # Fetch tokens
  #
  TokenSyncAPI.fetchByCompany(data.company.uuid)
  #UserSyncAPI.fetchByCompany(data.company.uuid)

  # Add loaded company
  #
  CompanyStore.add(data.company)
  

  # Access Rights component
  #
  AccessRightsComponent = require('components/company/access_rights')
  
  React.renderComponent(AccessRightsComponent({ key: data.company.uuid, roles: data.roles }), document.querySelector('[data-react-mount-point="access-rights"]'))
  
  
