# @cjsx React.DOM

# Imports
# 
# SomeComponent = require('')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'ShareButtons'

  propTypes:
    object: React.PropTypes.object.isRequired
    renderedInsideModal: React.PropTypes.bool

  # mixins: []
  # statics: {}


  # Component Specifications
  # 
  getDefaultProps: ->
    renderedInsideModal: false

  getInitialState: ->
    display_mode: null

  
  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->

  componentDidUpdate: (prevProps, prevState) ->
    if @refs.clip
      new ZeroClipboard(@refs.clip.getDOMNode())

    if @refs.copy_link_input
      copy_link_input = @refs.copy_link_input.getDOMNode()
      copy_link_input.setSelectionRange(0, copy_link_input.value.length)

  # componentWillUnmount: ->


  # Helpers
  # 
  openShareWindow: (url) ->
    window.open(url, '_blank', 'location=yes,width=640,height=480,scrollbars=yes,status=yes')


  # Handlers
  # 
  handleCopyLinkButtonClick: (event) ->
    @setState display_mode: 'copy_link'

  handleCopyLinkClick: (event) ->
    @setState display_mode: null

  handleFacebookLinkClick: (object, event) ->
    @openShareWindow(object.facebook_share_url)

  handleTwitterLinkClick: (object, event) ->
    @openShareWindow(object.twitter_share_url)


  # Renderers
  # 
  renderShareButtons: (object) ->
    <ul className="share-buttons">
      <li>
        <button className="cc" onClick={ @handleCopyLinkButtonClick }>Copy link</button>
      </li>

      <li>
        <button className="cc" onClick={@handleFacebookLinkClick.bind(@, object)}>
          <i className="fa fa-facebook"></i>
        </button>
      </li>

      <li>
        <button className="cc" onClick={@handleTwitterLinkClick.bind(@, object)}>
          <i className="fa fa-twitter"></i>
        </button>
      </li>
    </ul>

  renderCopyLinkSection: (object) ->
    <ul className="share-buttons">
      <li>
        <input id="copy_link_input" ref="copy_link_input" className="cc-input" value={ object.url } readOnly={true} />
      </li>

      <li>
        <button ref="clip" data-clipboard-target="copy_link_input" className="cc" onClick={@handleCopyLinkClick} title="Copy link to clipboard">
          <i className="fa fa-check"></i>
        </button>
      </li>
    </ul>


  # Main render
  # 
  render: ->
    if @state.display_mode is 'copy_link'
      @renderCopyLinkSection(@props.object)
    else
      @renderShareButtons(@props.object)
