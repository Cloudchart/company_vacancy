# @cjsx React.DOM

GlobalState = require('global_state/state')

PinboardStore = require('stores/pinboard_store')
UserStore = require('stores/user_store.cursor')

Pinboard = require('components/pinboards/pins/pinboard')
ModalStack = require('components/modal_stack')
ModalHeader = require('components/shared/modal_header')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'PinboardInsightsImporter'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pinboard: React.PropTypes.string.isRequired

  statics:
    queries:
      pinboards: ->
        """
          Viewer {
            available_pinboards {
              id,
              title
            },
            edges {
              available_pinboards_ids
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pinboards'))


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false
    sync: false
    selectedPinboard: ""


  # Lifecycle Methods
  #
  componentWillMount: ->
    @cursor =
      viewer: UserStore.me()

  componentDidMount: ->
    @fetch().then => @setState ready: true


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  handlePinboardsSelectChange: (event) ->
    @setState selectedPinboard: event.target.value

  handleCancelClick: (event) ->
    ModalStack.hide()

  handleSubmit: (event) ->
    event.preventDefault()
    return unless @state.selectedPinboard
    @setState sync: true

    PinboardStore.syncAPI.import_insights(@props.pinboard, @state.selectedPinboard).then =>
      GlobalState.fetch(Pinboard.getQuery('pins'), id: @props.pinboard, force: true)
      @setState sync: false
      ModalStack.hide()


  # Renderers
  #
  renderOptions: ->
    prompt = [ <option key=1 value="">{ '<Select collection>' }</option> ]
    options = @cursor.viewer.get('available_pinboards_ids')
      .filter (id) => id != @props.pinboard
      .map (id) => <option value={ id }>{ PinboardStore.get(id).get('title') }</option>

    prompt.concat(options)


  # Main render
  #
  render: ->
    return null unless @state.ready

    <form className="insights-importer" onSubmit={@handleSubmit}>
      <ModalHeader text={ 'Import insights' } />

      <fieldset>
        <label htmlFor="pinboard_id">Collection</label>
        <select id="pinboard_id" name="pinboard_id" value={ @state.selectedPinboard } onChange={ @handlePinboardsSelectChange }>
          { @renderOptions() }
        </select>
      </fieldset>

      <footer>
        <button className="cc cancel" onClick={ @handleCancelClick }>Cancel</button>
        <button className="cc" type="submit" disabled={ @state.sync }>Import</button>
      </footer>
    </form>
