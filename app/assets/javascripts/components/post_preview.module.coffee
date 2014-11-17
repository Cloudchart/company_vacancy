# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PostStore = require('stores/post_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

Post = require('components/post')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  gatherControls: ->
    if @props.readOnly
      # TODO: add show?
      null
    else
      <div className="controls">
        <i className="fa fa-edit" onClick={@handleEditClick}></i>
        <i className="fa fa-times-circle-o" onClick={@handleDestroyClick}></i>
      </div>

  # Handlers
  # 
  handleDestroyClick: (event) ->
    event.preventDefault()
    PostActions.destroy(@state.uuid) if confirm('Are you sure?')

  handleEditClick: (event) ->
    event.preventDefault()
    ModalActions.show(Post({ id: @props.id, company_id: @props.company_id }), class_for_container: 'post')

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->

  getStateFromStores: ->
    PostStore.get(@props.id).toJSON()

  getInitialState: ->
    @getStateFromStores()

  render: ->
    <article className="post preview">
      {@gatherControls()}
      <h1>{@state.title}</h1>
      <span className="date">{if moment(@state.published_at).isValid() then moment(@state.published_at).format('ll') else ''}</span>
    </article>

# Exports
# 
module.exports = Component
