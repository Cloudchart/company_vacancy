# @cjsx React.DOM

PinStore    = require('stores/pin_store')

cx = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'ReflectOnInsightForm'

  propTypes:
    insight:  React.PropTypes.string.isRequired
    onDone:   React.PropTypes.func.isRequired
    onCancel: React.PropTypes.func.isRequired


  getDefaultProps: ->
    status: true


  getInitialState: ->
    sync:       false
    errors:     []
    attributes:
      status:   @props.status
      content:  ''
      link:     ''


  createReflection: (params) ->
    @setState
      sync: true

    PinStore.create(params).then @createDone, @createFail


  createDone: ->
    @props.onDone()


  createFail: (xhr) ->
    @setState
      sync:   false
      errors: Object.keys(xhr.responseJSON.errors)


  handleSubmit: (event) ->
    event.preventDefault()

    return if @state.sync

    params =
      parent_id:    @props.insight
      is_approved:  @state.attributes.status
      kind:         'reflection'
      content:      @state.attributes.content
      origin:       @state.attributes.link

    @createReflection(params)


  handleChange: (name, event) ->
    attributes        = @state.attributes
    attributes[name]  = event.target.value

    errors            = [].concat(@state.errors)
    errorIndex        = errors.indexOf(name)
    errors.splice(errorIndex, 1) if errorIndex > -1

    @setState
      attributes: attributes
      errors:     errors


  handleStatusChange: (value, event) ->
    attributes            = @state.attributes
    attributes['status']  = value
    @setState
      attributes: attributes
      errors:     []


  renderStatus: ->
    <label className="status">
      <span className="title">
        <strong>Did it work?</strong>
      </span>
      <label className="part-1-of-2">
        <input
          type      = "radio"
          name      = "status"
          checked   = { @state.attributes['status'] }
          onChange  = { @handleStatusChange.bind(@, true) }
        />
        <span>Yes it worked</span>
      </label>
      <label className="part-1-of-2">
        <input
          type      = "radio"
          name      = "status"
          checked   = { !@state.attributes['status'] }
          onChange  = { @handleStatusChange.bind(@, false) }
        />
        <span>No it didn't</span>
      </label>
    </label>


  renderContent: ->
    classNames = cx
      content:  true
      error:    @state.errors.indexOf('content') > -1

    <label className={ classNames }>
      <span className="title">
        Tell us how it worked, give back to the community:
      </span>
      <textarea
        autoFocus = { true }
        rows      = 5
        value     = { @state.attributes['content'] }
        onChange  = { @handleChange.bind(@, 'content') }
      />
    </label>

  renderLink: ->
    <label className="link">
      <span className="title">
        Is there a post about that? The link:
      </span>
      <input
        type      = 'text'
        value     = { @state.attributes['link'] }
        onChange  = { @handleChange.bind(@, 'link') }
      />
    </label>


  renderSyncIcon: ->
    return null unless @state.sync
    <i className="fa fa-spin fa-spinner" />

  renderFooter: ->
    <footer>
      <button type="button" className="cc cancel" onClick={ @props.onCancel }>Cancel</button>
      <button type="submit" className="cc">
        Comment
        { @renderSyncIcon() }
      </button>
    </footer>



  render: ->
    <form className="reflect-on-insight" onSubmit={ @handleSubmit }>
      <fieldset>
        { @renderStatus() }
        { @renderContent() }
        { @renderLink() }
      </fieldset>
      { @renderFooter() }
    </form>
