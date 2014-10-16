# @cjsx React.DOM

@['companies/access_rights#index'] = (data) ->
  
  CompanyStore  = require('stores/company')
  TokenStore    = require('stores/token')
  UsersStore    = require('stores/users')
  RolesStore    = require('stores/roles')
  
  CompanyActions  = require('actions/company')

  promises = [
    CompanyActions.fetchAccessRights(data.company.uuid)
    CompanyActions.fetchInviteTokens(data.company.uuid)
  ]

  CompanyStore.add(data.company.uuid, data.company)
  AccessRights = require('components/company/access_rights')
  
  React.renderComponent(
    <AccessRights key=data.company.uuid invitable_roles=data.invitable_roles />,
    document.querySelector('[data-react-mount-point="access-rights"]'))
