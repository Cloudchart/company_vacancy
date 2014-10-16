###
  Used in:
  components/company/preview/list
###

tag = React.DOM

Logo = require('components/company/logo')
CompanyActions = require('actions/company')
TokenStore = require('stores/token')

MainComponent = React.createClass

  classNameForIconWithSync: (default_class_name, sync_token) ->
    if TokenStore.getSync(@props.token.uuid) == sync_token then 'fa fa-spinner fa-spin' else default_class_name

  gatherButtons: ->
    tag.div { className: "buttons" },
      (tag.button { 
        className: 'orgpad alert'
        onClick: @onDeclineClick
        disabled: TokenStore.getSync(@props.token.uuid) == 'create'
      },
        "Decline"
        tag.i { className: @classNameForIconWithSync('fa fa-close', 'create') }
      )
      (tag.button {
        className: 'orgpad'
        onClick: @onAcceptClick
        disabled: TokenStore.getSync(@props.token.uuid) == 'accept_invite'
      },
        "Accept"
        tag.i { className: @classNameForIconWithSync('fa fa-check', 'accept_invite') }
      )

  onAcceptClick: (event) ->
    event.preventDefault()
    event.stopPropagation()
    CompanyActions.acceptInvite(@props.token.uuid)

  onDeclineClick: (event) ->
    event.preventDefault()
    event.stopPropagation()
    CompanyActions.cancelInvite(@props.token.uuid)

  getDefaultProps: ->
    { renderButtons: false }

  render: ->
    company = @props.company

    if company
      tag.article { className: "company-preview" },
        tag.a { href: company.meta.company_url },
          tag.header null,
            Logo {
              logoUrl: company.logotype_url
              value: company.name || 'Unnamed'
            }
          tag.section { className: "middle" },
            tag.div { className: "left" },
              tag.div { className: "name" }, company.name || 'Unnamed'
              tag.div { className: "description" }, company.description
            tag.div { className: "right" },
              tag.div { className: "size" },
                company.meta.people_size
                tag.i { className: "fa fa-male" }
              # tag.div { className: "burn-rate" },
              #   "$300K"
              #   tag.span { className: "units" }, "month"
          tag.section { className: "bottom" },
            if @props.renderButtons
              @gatherButtons()
            else
              tag.p null, company.meta.tags.map((tag) -> "##{tag}").join(', ')
    else
      (tag.noscript null)


module.exports = MainComponent
