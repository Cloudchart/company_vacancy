@['companies/access_rights#index'] = (data) ->
  
  CompanyStore = require('stores/company_store')
  
  
  # Add loaded company
  #
  CompanyStore.add(data.company)
  

  # Access Rights component
  #
  AccessRightsComponent = require('components/company/access_rights')
  
  React.renderComponent(AccessRightsComponent({ key: 'abc' }), document.querySelector('[data-react-mount-point="access-rights"]'))
  
  
  # Invites component
  #
  InvitesComponent = require('components/company/invites')
  
  React.renderComponent(InvitesComponent({ key: data.company.uuid }), document.querySelector('[data-react-mount-point="invites"]'))
