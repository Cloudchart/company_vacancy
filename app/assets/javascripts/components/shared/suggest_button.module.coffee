# @cjsx React.DOM

ModalStack = require('components/modal_stack')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'SuggestButton'

  propTypes:
    uuid: React.PropTypes.string.isRequired
    type: React.PropTypes.string.isRequired
    label: React.PropTypes.string

  # mixins: []
  # statics: {}


  # Component Specifications
  #
  getDefaultProps: ->
    label: 'Suggest insight'

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
  handleClick: (event) ->
    SuggestionApp = require('components/suggestion_app')

    ModalStack.hide()

    ModalStack.show(
      <SuggestionApp uuid = { @props.uuid } type = { @props.type } />
    )

  # Renderers
  #
  # renderSomething: ->


  # Main render
  #
  render: ->
    <button className="cc suggest" onClick={@handleClick}>
      { @props.label }
    </button>
