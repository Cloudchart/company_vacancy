# @cjsx React.DOM

Dispatcher      = require('dispatcher/dispatcher')
GlobalState     = require('global_state/state')

# Stores
#
PinboardStore   = require('stores/pinboard_store')


# Utils
#
pinboardsSorter = (item) -> item.get('title')

pinboardsMapper = (item) ->
  <li key={item.get('uuid')}>
    <a href="#" onClick={@handleUpdatePinboardClick.bind(null, item.get('uuid'), item.get('title'))}>
      { item.get('title') }
    </a>

    &mdash;

    <a href="#" className="alert" onClick={@handleDestroyPinboardClick.bind(null, item.get('uuid'))}>
      &times;
    </a>
  </li>


# Exports
#
module.exports = React.createClass


  displayName: 'PinboardsApp'


  mixins: [GlobalState.mixin]


  gatherPinboards: ->
    @props.cursor.deref(PinboardStore.empty)
      .sortBy pinboardsSorter
      .map    pinboardsMapper.bind(@)


  handleCreatePinboardClick: (event) ->
    event.preventDefault()
    title = prompt('Pick a name') ; return unless title
    PinboardStore.create(title)
  

  handleUpdatePinboardClick: (id, title, event) ->
    event.preventDefault()
    title = prompt('Pick a title', title) ; return unless title
    PinboardStore.update(id, title)
  
  
  handleDestroyPinboardClick: (id, event) ->
    event.preventDefault()
    PinboardStore.destroy(id) if confirm('Are you sure?')
  

  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  componentDidMount: ->
    PinboardStore.fetchAll()
  
  
  getDefaultProps: ->
    cursor: GlobalState.cursor(['stores', 'pinboards', 'items'])


  render: ->
    pinboards = @gatherPinboards()

    <ul>
      { pinboards.toArray() }

      <li>
        <a href="#" onClick={@handleCreatePinboardClick}>
          Create new board
        </a>
      </li>
    </ul>
