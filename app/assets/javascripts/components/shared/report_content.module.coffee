# @cjsx React.DOM

# Imports
# 
CloseModalButton = require('components/form/buttons').CloseModalButton
ModalStack = require('components/modal_stack')
NotificationsPushApi = require('push_api/notifications_push_api')

# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'ReportContent'
  # propTypes:
    # some_object: React.PropTypes.object.isRequired
  # mixins: []
  # statics: {}


  # Component Specifications
  # 
  # getDefaultProps: ->

  getInitialState: ->
    url: location.href
    reason: ''
    errors: {}


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  # getSomething: ->


  # Handlers
  # 
  handleSubmit: (event) ->
    event.preventDefault()

    NotificationsPushApi
      .report_content(url: @state.url, reason: @state.reason)
      .then(@handleSubmitDone, @handleSubmitFail)

  handleSubmitDone: ->
    console.log 'handleSubmitDone'

  handleSubmitFail: (xhr) ->
    @setState errors: xhr.responseJSON.errors

  handleUrlChange: (event) ->
    @setState url: event.target.value

  handleReasonChange: (event) ->
    @setState reason: event.target.value

  handleCancelClick: (event) ->
    ModalStack.hide()


  # Renderers
  # 
  renderErrors: (attribute) ->
    return null unless errors = @state.errors[attribute]
    <span className="error">{ errors.join(', ') }</span>


  # Main render
  # 
  render: ->
    <form className="report-content" onSubmit={ @handleSubmit }>
      <CloseModalButton/>

      <header>
        { "Let us know why we should review this content" }
      </header>

      <fieldset>
        <label>
          <span>URL</span>
          <input
            value = { @state.url }
            placeholder = "Tap to add URL"
            onChange = { @handleUrlChange }
          />
          { @renderErrors('url') }
        </label>

        <label>
          <span>Reporting reason</span>
          <textarea
            autoFocus = "true"
            value = { @state.reason }
            placeholder = "Tap to add reporting reason"
            onChange = { @handleReasonChange }
          />
          { @renderErrors('reason') }
        </label>
      </fieldset>

      <footer>
        <button className="cc cancel" type="button" onClick={@handleCancelClick}>Cancel</button>
        <button className="cc" type="submit">Report content</button>
      </footer>

    </form>
