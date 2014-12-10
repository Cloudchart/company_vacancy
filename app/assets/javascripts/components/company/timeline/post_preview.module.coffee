# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')
ParagraphStore = require('stores/paragraph_store')
PictureStore = require('stores/picture_store')
VisibilityStore = require('stores/visibility_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')
VisibilityActions = require('actions/visibility_actions')

Post = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')
TagsComponent = require('components/company/tags')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  gatherControls: ->
    return null if @props.readOnly

    <ul className="controls">
      <li className="visibility">
        <select value={@state.visibility_value}, onChange={@handleVisibilityChange}>
          <option value={'public'}>Public</option>
          <option value={'trusted'}>Trusted</option>
          <option value={'only_me'}>Only me</option>
        </select>
      </li>
      <li>
        <i className="fa fa-times" onClick={@handleDestroyClick}></i>
      </li>
    </ul>

  getFirstParagraph: ->
    block = @getBlocksByIdentity('Paragraph')[0]
    paragraph =
      if block
        _.chain @state.paragraphs
          .filter (paragraph) -> paragraph.owner_id == block.uuid
          .first()
          .value()
      else
        null

    if paragraph and paragraph.content
      parts = paragraph.content.match(/<div>(.*?)<\/div>/i)
      content = "<div>#{_.str.truncate(parts[1], 600)}</div>"

      <div className="paragraph" dangerouslySetInnerHTML={__html: content}></div>
    else
      ''

  gatherPictures: ->
    block_ids = _.pluck @getBlocksByIdentity('Picture'), 'uuid'
    pictures = _.filter @state.pictures, (picture) -> _.contains block_ids, picture.owner_id

    if pictures.length == 1
      <img className="cover" src={pictures[0].url}/>
    else if pictures.length > 1
      <ul className="pictures">
        {
          _.map pictures, (picture) -> 
            <li key={picture.uuid} style={'background-image': "url(#{picture.url})"}></li>
        }
      </ul>
    else
      null      

  getBlocksByIdentity: (identity_type) ->
    _.chain BlockStore.all()
      .filter (block) => block.owner_id == @props.id and block.identity_type == identity_type
      .sortBy('position')
      .value()

  getHeader: ->
    formatted_date = if moment(@state.post.published_at).isValid()
      moment(@state.post.published_at).format('ll') 
    else ''

    title = if @state.post.title
      <h1>{@state.post.title}</h1>
    else
      <h1>{formatted_date}</h1>

    date = if @state.post.title
      <span className="date">{formatted_date}</span>
    else null
      
    <header>
      {title}
      {date}
      <TagsComponent taggable_id={@props.id} taggable_type='Post' readOnly={true} />
    </header>

  # Handlers
  # 
  handleDestroyClick: (event) ->
    event.preventDefault()
    PostActions.destroy(@state.post.uuid) if confirm('Are you sure?')

  handleEditClick: (event) ->
    event.preventDefault()
    ModalActions.show(Post({ 
      id: @props.id
      company_id: @props.company_id
      readOnly: @props.readOnly 
    }), class_for_container: 'post')

  handleVisibilityChange: (event) ->
    value = event.target.value

    if value is 'only_me' or value is 'trusted'
      if @state.visibility and @state.visibility.value isnt value
        VisibilityActions.update(@state.visibility.uuid, { value: value })
      else
        VisibilityActions.create(VisibilityStore.create(), { owner_id: @props.id, value: value })
        
    else if value is 'public' and @state.visibility.value
      @setState({ visibility: value })
      VisibilityActions.destroy(@state.visibility.uuid)

  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    ParagraphStore.on('change', @refreshStateFromStores)
    PictureStore.on('change', @refreshStateFromStores)
    VisibilityStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    ParagraphStore.off('change', @refreshStateFromStores)
    PictureStore.off('change', @refreshStateFromStores)
    VisibilityStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  # getDefaultProps: ->

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.id and item.owner_type is 'Post'

    post: PostStore.get(props.id)
    paragraphs: ParagraphStore.all()
    pictures: PictureStore.all()
    visibility: visibility
    visibility_value: if visibility then visibility.value else 'public'

  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    if @state.post
      <article className="preview post">
        {@gatherControls()}

        <a href="" onClick={@handleEditClick}>
          {@getHeader()}
          {@getFirstParagraph()}
          {@gatherPictures()}
        </a>
      </article>
    else
      null

# Exports
# 
module.exports = Component
