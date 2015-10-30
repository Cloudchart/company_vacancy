# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightReactions'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin: React.PropTypes.string.isRequired

  statics:
    queries:
      pin: ->
        """
          Pin {
            positive_reaction,
            negative_reaction
          }
        """

      viewer: ->
        """
          Viewer {
            edges {
              is_editor
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    Promise.all([ @fetchPin(), @fetchViewer() ]).then => @setState ready: true

  fetchPin: (options={}) ->
    GlobalState.fetch(@getQuery('pin'), _.extend(options, id: @props.pin)).then =>
      @setState
        attributes:
          positive_reaction: @cursor.pin.get('positive_reaction')
          negative_reaction: @cursor.pin.get('negative_reaction')

  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false
    isSyncing: false
    attributes:
      positive_reaction: ''
      negative_reaction: ''


  # Lifecycle Methods
  #
  componentWillMount: ->
    @cursor =
      pin: PinStore.cursor.items.cursor(@props.pin)
      viewer: UserStore.me()

  componentDidMount: ->
    @fetch()

  # componentWillUnmount: ->


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  handleSubmit: (event) ->
    event.preventDefault()
    @setState isSyncing: true
    PinStore.syncAPI.update(@cursor.pin, @state.attributes).then(@handleSubmitDone, @handleSubmitFail)

  handleAttributeChange: (attribute_name, event) ->
    attributes = @state.attributes
    attributes[attribute_name] = event.target.value
    @setState attributes: attributes

  handleSubmitDone: ->
    @setState isSyncing: false
    @fetchPin(force: true)

  handleSubmitFail: ->
    @setState isSyncing: false
    console.warn('Unable to submit')


  # Renderers
  #
  # renderSomething: ->


  # Main render
  #
  render: ->
    return null unless @state.ready && @cursor.viewer.get('is_editor')

    <div className="reactions">
      <h1>Reactions</h1>

      <form onSubmit={ @handleSubmit }>
        <textarea
          id="positive_reaction"
          name="positive_reaction"
          value={ @state.attributes.positive_reaction }
          placeholder="Positive reaction text"
          onChange={ @handleAttributeChange.bind(null, 'positive_reaction') }
        />

        <textarea
          id="negative_reaction"
          name="negative_reaction"
          value={ @state.attributes.negative_reaction }
          placeholder="Negative reaction text"
          onChange={ @handleAttributeChange.bind(null, 'negative_reaction') }
        />

        <button type="submit" className="cc" disabled={ @state.isSyncing }>Update</button>
      </form>
    </div>
