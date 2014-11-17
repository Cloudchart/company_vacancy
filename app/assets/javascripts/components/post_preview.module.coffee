# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')
ParagraphStore = require('stores/paragraph_store')
PictureStore = require('stores/picture_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

Post = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')

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

  getFirstParagraph: ->
    block = @getBlocksByIdentity('Paragraph')[0]
    paragraph = if block then ParagraphStore.filter((paragraph) -> paragraph.owner_id == block.uuid)[0] else null

    if paragraph
      <div className="paragraph" dangerouslySetInnerHTML={__html: paragraph.content}></div>
    else
      ''

  gatherPictures: ->
    block_ids = _.pluck @getBlocksByIdentity('Picture'), 'uuid'
    pictures = _.chain PictureStore.all()
      .filter (picture) -> _.contains block_ids, picture.owner_id
      .map (picture) -> <li key={picture.uuid}><img src={picture.url}/></li>
      .value()

    <ul className="pictures">
      {pictures}
    </ul>

  getBlocksByIdentity: (identity_type) ->
    _.chain BlockStore.all()
      .filter (block) => block.owner_id == @props.id and block.identity_type == identity_type
      .sortBy('position')
      .value()

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

  # TODO: refresh state from picture and paragraph stores

  getStateFromStores: ->
    PostStore.get(@props.id).toJSON()

  getInitialState: ->
    @getStateFromStores()

  render: ->
    <article className="post preview">
      {@gatherControls()}

      <header>
        <h1>{@state.title}</h1>
        <span className="date">{if moment(@state.published_at).isValid() then moment(@state.published_at).format('ll') else ''}</span>
      </header>

      {@getFirstParagraph()}
      {@gatherPictures()}
    </article>

# Exports
# 
module.exports = Component
