# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

UserPinboards = require('components/pinboards/lists/user')
PinboardsList = require('components/pinboards/pinboards')

# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'SuggestionApp'
  
  propTypes:
    uuid: React.PropTypes.string.isRequired
    type: React.PropTypes.string.isRequired
  
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            #{UserPinboards.getQuery('pinboards')}
          }
        """

  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
      viewer: UserStore.me()

  getInitialState: ->
    fetchDone: false


  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch().then => @setState fetchDone: true

  # componentDidMount: ->
  # componentWillUnmount: ->


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Helpers
  # 
  getPinboards: ->
    # PinboardStore
    #   .filterUserPinboards(@props.user_id, showPrivate: @props.showPrivate)
    #   .sortBy (item) -> item.get('title')
    #   .valueSeq()
    #   .toArray()

    @props.cursor.pinboards
      .sortBy (pinboard) -> pinboard.get('title')
      .valueSeq()
      .toArray()


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    return null unless @state.fetchDone

    <PinboardsList 
      pinboards = { @getPinboards() }
      user_id = { @props.cursor.viewer.get('uuid') }
    />
