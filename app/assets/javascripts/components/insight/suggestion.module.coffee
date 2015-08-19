# @cjsx React.DOM

# Imports
# 
Constants = require('constants')

UserStore = require('stores/user_store.cursor')
PinStore = require('stores/pin_store')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'InsightSuggestion'
  
  propTypes:
    pin: React.PropTypes.object.isRequired

  # mixins: []
  # statics: {}


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillUnmount: ->


  # Fetchers
  #
  # fetch: ->


  # Helpers
  # 
  # getSomething: ->


  # Handlers
  # 
  handleSuggestionDeleteButton: ->
    PinStore.destroy(@props.pin.uuid) if confirm('Are you sure?')


  # Renderers
  # 
  renderSuggestionDeleteButton: ->
    return null unless UserStore.isEditor()

    <button className="transparent" onClick={@handleSuggestionDeleteButton}>
      <i className="cc-icon cc-times"></i>
    </button>


  # Main render
  # 
  render: ->
    return null unless @props.pin.is_suggestion

    <section className="suggestion">
      <i className="svg-icon svg-cloudchart-logo" />
      <span>{ "Suggested by #{Constants.SITE_NAME}" }</span>
      { @renderSuggestionDeleteButton() }
    </section>
