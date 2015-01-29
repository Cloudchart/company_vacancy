##= require cloud_blueprint/react/chart_preview

# Activities
#
@['cloud_profile/main#activities'] = (data) ->
  $ -> cc.ujs.scrollable_pagination()


# Companies
#
@['cloud_profile/main#companies'] = ->
  CompanySync = require('sync/company')

  CompanyStore = require('stores/company')
  TokenStore = require('stores/token_store')
  RoleStore = require('stores/role_store')
  FavoriteStore = require('stores/favorite')
  Dispatcher = require('dispatcher/dispatcher')

  CompanyPreviewList = require('components/company/preview/list')

  CompanySync.fetchAll().done((json) ->
    
    Dispatcher.handleServerAction
      type: 'company:fetch:many:done'
      data: [json]

    _.each json.companies, (company) ->
      CompanyStore.add(company.uuid, company)

    _.each json.tokens, (token) ->
      TokenStore.add(token.uuid, token)

    _.each json.roles, (role) ->
      RoleStore.add(role.uuid, role)

    _.each json.favorites, (favorite) ->
      FavoriteStore.add(favorite.uuid, favorite)

    React.renderComponent(
      CompanyPreviewList()
      document.querySelector('body > main')
    )
  )


# Settings
#
@['cloud_profile/main#settings'] = (data) ->

  # Settings / Personal
  #
  if personalComponentMountPoint = document.querySelector('[data-react-mount-point="personal"]')

    PersonalComponent = cc.require('profile/react/settings/personal')
    
    React.renderComponent PersonalComponent(data.personal), personalComponentMountPoint

  
  # Account /Emails
  #
  if accountMountPoint = document.querySelector('[data-react-mount-point="account"]')
    AccountComponent = cc.require('profile/react/settings/account')
    
    React.renderComponent(
      (AccountComponent {
        emails: data.personal.emails
        verification_tokens: data.personal.verification_tokens
        readOnly: false
        emails_path: data.emails_path
      })
      accountMountPoint
    )
