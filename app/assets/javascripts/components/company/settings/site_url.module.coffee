# @cjsx React.DOM

tag = React.DOM
# regex = /(.+)\.(.+)/

CompanyStore = require('stores/company')

# # CheckFileComponent
# # 
# CheckFileComponent = React.createClass
#   render: ->
#     (tag.button {
#       className: 'orgpad'
#       disabled: true if @state.sync
#       onClick: @checkFile
#     },
#       (tag.span {}, 'Check file')
#       (tag.i {
#         className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-file-text-o'
#       })
#     )

#   getInitialState: ->
#     sync: false

#   checkFile: ->
#     @setState({ sync: true })

#     $.ajax
#       url: @props.verify_site_url
#       type: 'GET'
#       dataType: 'json'

#     .done @onCheckFileDone
#     .fail @onCheckFileFail

#   onCheckFileDone: (json) ->
#     @setState({ sync: false })

#     if json == 'ok'
#       is_site_url_verified = true
#       site_url_verification_failed = false
#     else
#       is_site_url_verified = false
#       site_url_verification_failed = true

#     @props.onChange(
#       target:
#         is_site_url_verified: is_site_url_verified
#         site_url_verification_failed: site_url_verification_failed
#     )

#   onCheckFileFail: (json) ->
#     @setState({ sync: false })
#     console.warn 'checkFile fail'

# # CancelVerificationComponent
# # 
# CancelVerificationComponent = React.createClass
  
#   render: ->
#     # <button
#     #   className="orgpad alert"
#     #   disabled={true if @state.sync}
#     #   onClick=@save
#     # />
#     #   <span>{@props.button_value}</span>
#     #   <i className={if @state.sync then 'fa fa-spinner fa-spin' else @props.button_icon}></i>
#     # </button>

#   getInitialState: ->
#     value: ''
#     sync: false

#   save: ->
#     data = new FormData
#     data.append('company[site_url]', @state.value)

#     @setState({ sync: true })

#     $.ajax
#       url: @props.company_url
#       data: data
#       type: 'PUT'
#       dataType: 'json'
#       contentType: false
#       processData: false

#     .done @onSaveDone
#     .fail @onSaveFail

#   onSaveDone: (json) ->
#     @setState({ sync: false })

#     @props.onChange(
#       target:
#         value: @state.value
#         verification_sent: false
#         is_site_url_verified: false
#         site_url_verification_failed: false
#     )
  
#   onSaveFail: ->
#     @setState({ sync: false })
#     console.warn 'CancelVerificationComponent save fail'

#   getStateFromStores: ->
#     company: CompanyStore.get(@props.id)
#     sync: CompanyStore.getSync(@props.id) == 'publish'

#   componentWillReceiveProps: (nextProps) ->
#     @setState(@getStateFromStores())

#   getInitialState: ->
#     @getStateFromStores()

# MainComponent
#
UrlComponent = React.createClass

  # Component Specifications
  #
  render: ->
  
      if @state.is_site_url_verified
        <div className="profile-item">
          <div className="content field">
            <span className="label">Site URL</span>
            {@formattedSiteLink(@state.value)}
            <i className="fa fa-check-circle"></i>
          </div>

          <div className="actions">
            <CancelVerificationComponent
              company_url=@props.company_url
              onChange=@onCancelButtonChange
              button_value="Remove"
              button_icon="fa fa-eraser"
            />
          </div>
        </div>
      # else if @state.verification_sent
      #   <div className="profile-item">
      #     <div className="content paragraph">
      #       { <strong>File not found.</strong> if @state.site_url_verification_failed }
      #       <a href={@props.download_verification_file_url}>Download this file</a>
      #       <span> and make it accessible from the root directory of your domain </span>
      #       {@formattedSiteLink(@state.value)}
      #     </div>

      #     <div className="actions">
      #       <CheckFileComponent
      #         verify_site_url={@props.verify_site_url}
      #         onChange={@onCheckFileChange}
      #       />

      #       <CancelVerificationComponent
      #         company_url={@props.company_url}
      #         onChange={@onCancelButtonChange}
      #         button_value="Cancel"
      #         button_icon="fa fa-undo"
      #       />          
      #     </div>
      #   </div>
      # else
      #   <div className="profile-item">
      #     <div className="content field">
      #       <label htmlFor="site_url">Site URL</label>

      #       <div className="spacer"></div>

      #       <input
      #         id="site_url"
      #         name="site_url"
      #         value={@state.value}
      #         placeholder="www.example.com"
      #         className={"error" if @state.error}
      #         onChange={@onChange}
      #         onKeyUp={@onKeyUp}
      #       />
      #     </div>

      #     <div className="actions">
      #       <button
      #         className: "orgpad"
      #         disabled: true if !@isValid() or @state.sync
      #         onClick: {@save}>
      #         <span>Verify</span>
      #         <i className={ if @state.sync then "fa fa-spinner fa-spin" else "fa fa-paper-plane-o" }></i>
      #       </button>
      #     </div>
      #   </div>

  # getInitialState: ->
  #   value: @props.value
  #   verification_sent: @props.verification_sent
  #   is_site_url_verified: @props.is_site_url_verified
  #   site_url_verification_failed: @props.site_url_verification_failed
  #   sync: false
  #   error: false
  #   verification_sent:
  #     if @props.value == null or @props.value == '' then false else true

  # # getDefaultProps: ->

  # formattedSiteLink: (value) ->
  #   if /http:\/\/|https:\/\//.test(value)
  #     formatted_site_url = value
  #   else
  #     formatted_site_url = 'http://' + value

  #   (tag.a { href: formatted_site_url, target: '_blank' }, value)

  # onChange: (event) ->
  #   @setState({ value: event.target.value })

  # onCancelButtonChange: (event) ->
  #   @setState
  #     value: event.target.value 
  #     verification_sent: event.target.verification_sent
  #     is_site_url_verified: event.target.is_site_url_verified
  #     site_url_verification_failed: event.site_url_verification_failed

  # onCheckFileChange: (event) ->
  #   @setState
  #     is_site_url_verified: event.target.is_site_url_verified
  #     site_url_verification_failed: event.target.site_url_verification_failed

  # onKeyUp: (event) ->
  #   switch event.key
  #     when 'Enter'
  #       @save() if @isValid()
  #     when 'Escape'
  #       @undo()

  # isValid: ->
  #   regex.test(@state.value)

  # save: ->
  #   data = new FormData
  #   data.append('company[site_url]', @state.value)

  #   @setState({ sync: true, error: false })

  #   $.ajax
  #     url: @props.company_url
  #     data: data
  #     type: 'PUT'
  #     dataType: 'json'
  #     contentType: false
  #     processData: false

  #   .done @onSaveDone
  #   .fail @onSaveFail

  # onSaveDone: (json) ->
  #   @setState
  #     sync: false
  #     verification_sent: true
  #     is_site_url_verified: false
  
  # onSaveFail: ->
  #   @setState
  #     sync: false
  #     error: true

  # undo: ->
  #   @setState
  #     value: ''
  #     error: false

# Exports
#
module.exports = UrlComponent
