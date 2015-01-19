# @cjsx React.DOM


CloudFlux = require('cloud_flux')


# Stores
#
PostStore     = require('stores/post_store')
CompanyStore  = require('stores/company')


# Actions
#
PostActions = require('actions/post_actions')


# Utils
#


# Components
#
CompanyPreview = React.createClass


  getLogo: ->
    if @props.company.logotype_url
      <img src={@props.company.logotype_url} />
    

  getEstablishedDate: ->
    if @props.company.established_on
      <span className="established-on">{ moment(@props.company.established_on).format('ll') }</span>
  
  
  getButtons: ->
    <ul className="buttons">
      <li onClick={@props.onPinButtonClick}>
        <i className="fa fa-thumb-tack" />
      </li>
    </ul>


  render: ->
    return null unless @props.company
    
    <header className="company">
      { @getLogo() }
      { @getEstablishedDate() }
      { @getButtons() }
    </header>


# Exports
#
module.exports = React.createClass


  getCompany: ->
    <CompanyPreview company={ @state.company } onPinButtonClick={ @props.onPinButtonClick } />


  getPinContent: ->
    if @props.content
      <div className="content">
        { @props.content }
      </div>


  getStateFromStores: ->
    post = PostStore.get(@props.uuid)

    post:     post
    company:  CompanyStore.get(post.owner_id) if post
  

  refreshStateFromStores: ->
    @setState @getStateFromStores()


  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)
    CompanyStore.on('change', @refreshStateFromStores)
    
    PostActions.fetchOne(@props.uuid) unless @state.post
  

  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)
    CompanyStore.off('change', @refreshStateFromStores)
  
  
  getInitialState: ->
    @getStateFromStores()


  render: ->
    return null unless @state.post

    <div className="post">
      { @getCompany() }

      { @getPinContent() }
      
      <section className="post">
        <header dangerouslySetInnerHTML = { __html: @state.post.title } />
      </section>

    </div>
