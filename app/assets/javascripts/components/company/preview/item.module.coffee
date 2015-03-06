###
  Used in:
  components/company/preview/list
###

tag = React.DOM

Logo = require('components/company/logo')
CompanyActions = require('actions/company')
TokenStore = require('stores/token_store')
GlobalState = require('global_state/state')

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
    renderButtons: false
  
  
  getInitialState: ->
    cursor = GlobalState.cursor(['stores', 'companies'])

    cursor:
      meta:     GlobalState.cursor(['stores', 'companies', 'meta', @props.company.uuid])

  render: ->
    company = @props.company
    
    if company
      tag.article { className: "company-preview" },
        tag.a { href: @state.cursor.meta.get('company_url') },
          tag.header null,
            Logo {
              logoUrl: company.logotype_url
              value: company.name || 'Unnamed'
            }
          tag.section { className: "middle" },
            tag.div { className: "left" },
              tag.div { className: "name" }, company.name || 'Unnamed'
              tag.div { className: "description", dangerouslySetInnerHTML: {__html: company.description} }
            tag.div { className: "right" },
              tag.div { className: "size" },
                tag.div { className: 'vacancies' },
                  @state.cursor.meta.get('vacancies_size')
                  tag.i { className: "fa fa-briefcase" }
                tag.div { className: 'people' },
                  @state.cursor.meta.get('people_size')
                  tag.i { className: "fa fa-male" }
              # tag.div { className: "burn-rate" },
              #   "$300K"
              #   tag.span { className: "units" }, "month"
          tag.footer null,
            if @props.renderButtons
              @gatherButtons()
            else
              tag.p null, company.tag_names.map((tag) -> "##{tag}").join(', ')
    else
      (tag.noscript null)


module.exports = MainComponent
