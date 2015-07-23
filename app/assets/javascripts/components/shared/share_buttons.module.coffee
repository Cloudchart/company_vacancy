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

  # mixins: []
  # statics: {}


  # Component Specifications
  #
  getDefaultProps: ->
    displayMode: null

  getInitialState: ->
    displayMode: @props.displayMode


  # Lifecycle Methods
  #
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->


  handleChange: ->
    false


  componentDidUpdate: (prevProps, prevState) ->
    if @refs.clip
      new ZeroClipboard(@refs.clip.getDOMNode())

  # componentWillUnmount: ->


  # Helpers
  #
  openShareWindow: (url) ->
    window.open(url, '_blank', 'location=yes,width=640,height=480,scrollbars=yes,status=yes')

  setDefaultDisplayMode: ->
    @setState displayMode: @props.displayMode


  # Handlers
  #
  handleCopyLinkButtonClick: (event) ->
    @setState displayMode: 'copy_link'

  handleCopyLinkClick: (event) ->
    @setDefaultDisplayMode()

  handleFacebookLinkClick: (object, event) ->
    @openShareWindow(object.facebook_share_url)
    @setDefaultDisplayMode()

  handleTwitterLinkClick: (object, event) ->
    @openShareWindow(object.twitter_share_url)
    @setDefaultDisplayMode()

  handleShareButtonClick: (event) ->
    @setState displayMode: null


  # Renderers
  #
  renderShareButton: ->
    <button className="cc share" onClick={@handleShareButtonClick}>Share</button>

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
        <input id="copy_link_input" autoFocus={ true } onChange={ @handleChange } ref="copy_link_input" className="cc-input" value={ object.url } />
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
    switch @state.displayMode
      when 'single_button'
        @renderShareButton()
      when 'copy_link'
        @renderCopyLinkSection(@props.object)
      else
        @renderShareButtons(@props.object)
