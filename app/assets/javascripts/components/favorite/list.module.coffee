# @cjsx React.DOM

# Imports
# 
UserStore = require('stores/user_store.cursor')
FavoriteStore = require('stores/favorite_store.cursor')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'Favorite list'
  # mixins: []
  # propTypes: {}
  # uuid: React.PropTypes.string.isRequired


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  # gatherSomething: ->


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    me = UserStore.me()

    <div className="">
      { me.get('full_name') }
      { 
        FavoriteStore.cursor.items
          .filter (item) -> item.get('user_id') is me.get('uuid')
          .toArray()
          .map (item) -> <p>{ item.get('favoritable_type') }</p>
      }
    </div>


# Exports
# 
module.exports = MainComponent
