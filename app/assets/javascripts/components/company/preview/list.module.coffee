###
  Used in:
  cloud_profile/controllers/main
###

tag = React.DOM

CompanyStore = require('stores/company')
TokenStore = require('stores/token')
CompanyPreviewItem = require('components/company/preview/item')

MainComponent = React.createClass

  refreshStateFromStore: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    companies: CompanyStore.all()

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)

  getInitialState: ->
    @getStateFromStores()

  getTokenByCompany: (company) ->
    TokenStore.find (item) =>
      item.owner_id == company.id

  getMyCompanyItems: ->
    @getItemsForCompanies(
      (@state.companies.filter (company) ->
        company.flags.is_in_company
      ), "my"
    )

  getFollowedCompanyItems: ->
    @getItemsForCompanies(
      (@state.companies.filter (company) ->
        company.is_followed
      ), "followed"
    )

  getInvitedByCompanyItems: ->
    @getItemsForCompanies(
      (@state.companies.filter (company) ->
        company.flags.is_invited
      ), "invited", true
    )

  getItemsForCompanies: (companies, keyPrefix, renderButtons = false) ->
    self = @

    _.map(companies, (company) ->
      if company.flags.is_invited
        token = self.getTokenByCompany(company)

      CompanyPreviewItem {
        company: company
        key: "#{keyPrefix}-#{company.uuid}"
        renderButtons: renderButtons
        token: token
      }
    )

  render: ->
    myCompanyItems = @getMyCompanyItems()
    followedCompanyItems = @getFollowedCompanyItems()
    invitedCompanyItems = @getInvitedByCompanyItems()

    tag.section { className: "company-previews" },
      tag.section { className: "owned" },
        tag.h2 null, "My Companies"
        tag.div { className: "container" },
          myCompanyItems
          tag.div { className: "company-add" },
            tag.a null,
              tag.i { className: "fa fa-plus" }


      if invitedCompanyItems.length > 0
        tag.section { className: "invited" },
          tag.h2 null, "Invited to"
          tag.div { className: "container" },
            invitedCompanyItems

      if followedCompanyItems.length > 0
        tag.section { className: "followed" },
          tag.h2 null, "Following"
          tag.div { className: "container" },
            followedCompanyItems


module.exports = MainComponent
