# @cjsx React.DOM

# Imports
# 
tag = React.DOM

cx = React.addons.classSet

CompanyStore = require("stores/company")
CompanyActions = require("actions/company")

# Main Component
# 
Progress = React.createClass

  # Helpers
  #     
  progressItems: (company) ->
    [
      { message: "Give your company a name", passed: !!@state.company.name }
      { message: "Upload logo", passed: !!@state.company.meta.logotype_url }
      { message: "Create first chart", passed: @state.company.flags.has_charts }
      { message: "Add some people", passed: @state.company.meta.people_size > 0 }
      { message: "Assign keywords", passed: @state.company.meta.tags.length > 0 }
    ]

  progressItemsLeft: ->
    _.filter @progressItems(), (item) ->
      !item.passed
    .length

  progressStateMessage: ->
    if @state.company.is_published
      "Your company is published."
    else
      "Your company is unpublished. It means that users won't be able find your company unless you provide them with a direct link."

  progressStatusMessage: ->
    items_left = @progressItemsLeft()

    if items_left == 0 and !@state.company.is_published
      "Looks good. You may now publish your company."
    else if items_left == 1
      "There is one more step to publish your company:"
    else
      "There are #{items_left} steps to publish your company:"

  getProgressItems: ->
    _.map(_.sortBy(@progressItems(), (item) -> !item.passed), (item, index) ->
      <li key={index}>
        <span className={cx(checked: item.passed)}>{item.message}</span>
        {<i className="fa fa-check"></i> if item.passed }
      </li>
    )

  classForButtonIcon: ->
    if @state.sync
      "fa fa-spinner fa-spin"
    else if @state.company.is_published
      "fa fa-undo"
    else
      "fa fa-globe"

  getStateFromStores: ->
    sync = CompanyStore.getSync(@props.uuid) == "publish"
    state = { sync: sync }
    state.company = CompanyStore.get(@props.uuid) unless sync
    state

  # Handlers
  # 
  handlePublishClick: ->
    CompanyActions.update(@props.uuid, { is_published: !@state.company.is_published }, "publish")

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())

  # Component specifications
  #
  getInitialState: ->
    @getStateFromStores()

  render: ->
    company = @state.company

    if company
      <div className="section-block">
        <p>{@progressStateMessage()}</p>
        {
          <p>{@progressStatusMessage()}</p>
          <ul>
            { @getProgressItems() }
          </ul> unless @state.company.is_published 
        }
        <button className="orgpad"
                onClick={@handlePublishClick}
                disabled={@progressItemsLeft() > 0 or @state.sync}>
          <span>{if company.is_published then "Unpublish" else "Publish"}</span>
          <i className={@classForButtonIcon()}></i>
        </button>
      </div>

# Exports
# 
module.exports = Progress
