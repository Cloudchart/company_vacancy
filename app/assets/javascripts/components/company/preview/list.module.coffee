# TODO: move to cloud_profile

###
  Used in:
  cloud_profile/controllers/main
###

tag = React.DOM

CompanyStore = require('stores/company')
TokenStore = require('stores/token_store')
RoleStore = require('stores/role_store')
FavoriteStore = require('stores/favorite')

CompanyPreviewItem = require('components/company/preview/item')

MainComponent = React.createClass

  refreshStateFromStore: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    companies: CompanyStore.all()
    tokens: TokenStore.all()
    roles: RoleStore.all()
    favorites: FavoriteStore.all()

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStore)
    TokenStore.on('change', @refreshStateFromStore)
    RoleStore.on('change', @refreshStateFromStore)
    FavoriteStore.on('change', @refreshStateFromStore)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStore)
    TokenStore.off('change', @refreshStateFromStore)
    RoleStore.off('change', @refreshStateFromStore)
    FavoriteStore.off('change', @refreshStateFromStore)

  getInitialState: ->
    @getStateFromStores()

  getTokenByCompany: (company) ->
    _.filter(@state.tokens, (token) -> token.owner_id == company.uuid)[0]

  getMyCompanyItems: ->
    @getItemsForCompanies(
      (@state.companies.filter (company) =>
        _.contains(_.pluck(@state.roles, 'owner_id'), company.uuid)
      ), "my"
    )

  getFollowedCompanyItems: ->
    @getItemsForCompanies(
      (@state.companies.filter (company) =>
        _.contains(_.pluck(@state.favorites, 'favoritable_id'), company.uuid)
      ), "followed"
    )

  getInvitedByCompanyItems: ->
    @getItemsForCompanies(
      (@state.companies.filter (company) =>
        _.contains(_.pluck(@state.tokens, 'owner_id'), company.uuid)
      ), "invited", true
    )

  getItemsForCompanies: (companies, keyPrefix, renderButtons = false) ->
    _.map(companies, (company) =>
      
      CompanyPreviewItem {
        company: company
        key: "#{keyPrefix}-#{company.uuid}"
        renderButtons: renderButtons
        token: @getTokenByCompany(company) if keyPrefix == "invited"
      }
    )

  render: ->

    myCompanyItems = @getMyCompanyItems()
    invitedCompanyItems = @getInvitedByCompanyItems()
    followedCompanyItems = @getFollowedCompanyItems()

    tag.section { className: "cloud-profile-companies" },
      tag.section { className: "owned" },
        tag.h2 null, "My Companies"
        tag.div { className: "company-previews" },
          myCompanyItems
          tag.div { className: "company-add" },
            tag.a { href: '/companies/new' },
              tag.i { className: "fa fa-plus" }
              tag.span { className: 'hint' }, 'Create company'


      if invitedCompanyItems.length > 0
        tag.section { className: "invited" },
          tag.h2 null, "Invited to"
          tag.div { className: "company-previews" },
            invitedCompanyItems

      if followedCompanyItems.length > 0
        tag.section { className: "followed" },
          tag.h2 null, "Following"
          tag.div { className: "company-previews" },
            followedCompanyItems


module.exports = MainComponent
