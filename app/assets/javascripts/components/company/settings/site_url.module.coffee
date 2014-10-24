# @cjsx React.DOM

tag = React.DOM

CompanyStore    = require("stores/company")
CompanyActions  = require("actions/company")
CloudFluxMixins = require("cloud_flux/mixins")
Constants       = require("constants")

# CheckFileComponent
# 
CheckFileComponent = React.createClass

  # Helpers
  # 
  verify: ->
    CompanyActions.verifySiteUrl(@props.uuid)

  getStateFromStores: ->
    sync: CompanyStore.getSync(@props.uuid) == "verify_site_url"

  # Lifecycle Methods
  # 
  componentWillReceiveProps: ->
    @setState(@getStateFromStores())  

  # Component specifications
  #
  getInitialState: ->
    @getStateFromStores()

  render: ->
    <button
      className = "orgpad"
      disabled  = {true if @state.sync}
      onClick   = @verify>
      <span>Check file</span>
      <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-file-text-o"}></i>
    </button>

# CancelVerificationComponent
# 
CancelVerificationComponent = React.createClass

  # Helpers
  # 
  update: ->
    CompanyActions.update(@props.uuid, { site_url: "" }, "site_url")

  getStateFromStores: ->
    sync: CompanyStore.getSync(@props.uuid) == "site_url"

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())  

  # Component specifications
  #
  getInitialState: ->
    @getStateFromStores()
  
  render: ->
    <button
      className = "orgpad alert"
      disabled  = {true if @state.sync}
      onClick   = @update>
      <span>{@props.name}</span>
      <i className={if @state.sync then "fa fa-spinner fa-spin" else @props.icon}></i>
    </button>


UpdateSiteUrlComponent = React.createClass

  # Helpers
  # 
  update: ->
    CompanyActions.update(@props.uuid, { site_url: @state.site_url }, "site_url")

  isValid: ->
    /(.+)\.(.+)/.test(@state.site_url)

  undo: ->
    @setState
      site_url: ""

  # Handlers
  # 
  onChange: (event) ->
    @setState
      site_url: event.target.value 

  onKeyUp: (event) ->
    switch event.key
      when "Enter"
        @update() if @isValid()
      when "Escape"
        @undo()

  # Lifecycle Methods
  # 
  getStateFromStores: (props) ->
    sync:    CompanyStore.getSync(props.uuid) == "site_url"
    siteUrl: props.site_url

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))  

  # Component specifications
  #
  getInitialState: ->
    @getStateFromStores(@props)
  
  render: ->
    <div className="profile-item">
      <div className="content field">
        <label htmlFor="site_url">Site URL</label>
        <div className="spacer"></div>
        <input
          id          = "site_url"
          name        = "site_url"
          value       = {@state.site_url}
          placeholder = "www.example.com"
          onChange    = {@onChange}
          onKeyUp     = {@onKeyUp}
        />
      </div>
      <div className="actions">
        <button
          className = "orgpad"
          disabled  = {!@isValid() or @state.sync}
          onClick   = @update
        >
          <span>Verify</span>
          <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-paper-plane-o"}></i>
        </button>
      </div>
    </div>


# MainComponent
#
UrlComponent = React.createClass

  mixins: [CloudFluxMixins.Actions]

  getCloudFluxActions: ->
    actions = {}

    actions[Constants.Company.VERIFY_SITE_URL_DONE] = @onVerifyDone

    actions

  # Helpers
  # 
  formatSiteUrl: (site_url) ->
    if /http:\/\/|https:\/\//.test(site_url)
      formatted_site_url = site_url
    else
      formatted_site_url = "http://" + site_url

    <a href=formatted_site_url target="_blank">{site_url}</a>

  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)

  # Handlers
  # 
  onVerifyDone: (key, json) ->
    if json == "ok"
      @setState
        site_url_verification_failed: false
    else if json == "fail"
      @setState
        site_url_verification_failed: true

  # Lifecycle Methods
  # 
  componentWillReceiveProps: ->
    @setState(@getStateFromStores())

  # Component specifications
  #
  getInitialState: ->
    @getStateFromStores()

  render: ->
    company = @state.company

    if company
      if company.flags.is_site_url_verified
        <div className="profile-item">
          <div className="content field">
            <span className="label">Site URL</span>
            {@formatSiteUrl(company.site_url)}
            <i className="fa fa-check-circle"></i>
          </div>
          <div className="actions">
            <CancelVerificationComponent
              uuid = @props.uuid
              name = "Remove"
              icon = "fa fa-eraser"
            />
          </div>
        </div>
      else if company.site_url
        <div className="profile-item">
          <div className="content paragraph">
            {<strong>File not found. </strong> if @state.site_url_verification_failed}
            <a href={company.meta.download_verification_file_url}>Download this file</a>
            <span> and make it accessible from the root directory of your domain </span>
            {@formatSiteUrl(company.site_url)}
          </div>

          <div className="actions">
            <CheckFileComponent uuid=@props.uuid />
            <CancelVerificationComponent
              uuid = @props.uuid
              name = "Cancel"
              icon = "fa fa-undo"
            />          
          </div>
        </div>      
      else 
        <UpdateSiteUrlComponent 
          uuid    = @props.uuid
          siteUrl = company.site_url
        />
    else
      null

# Exports
#
module.exports = UrlComponent
