# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')
PinStore = require('stores/pin_store')
PostStore = require('stores/post_store.cursor')

Insight = require('components/cards/insight_card')
Pinboard = require('components/cards/pinboard_card')
Post = require('components/pinnable/post')


# Utils
#
# cx = React.addons.classSet

ObjectsForMainList =
  pins: 'Pin'
  pinboards: 'Pinboard'

getFeedData = (query) ->
  query[query.ids[0]]


# Main component
#
module.exports = React.createClass

  displayName: 'FeedMainList'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  # propTypes:
    # some_object: React.PropTypes.object.isRequired

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            feed_pins {
              #{Insight.getQuery('pin')}
            },
            feed_pinboards {
              #{Pinboard.getQuery('pinboard')}
            },
            feed_featured_posts {
              #{Post.getQuery('post')}
            },
            feed_featured_pinboards {
              #{Pinboard.getQuery('pinboard')}
            }
          }
        """

  # Fetchers
  #
  fetch: (date = @props.date) ->
    GlobalState.fetch(@getQuery('viewer'), { force: true, params: { date: @props.date } }).then (json) => 
      { feed_pins, feed_pinboards, feed_featured_posts, feed_featured_pinboards } = getFeedData(json.query)

      @setState
        ready: true
        pins_ids: feed_pins || []
        pinboards_ids: feed_pinboards || []
        featured_posts_ids: feed_featured_posts || []
        featured_pinboards_ids: feed_featured_pinboards || []


  # Component Specifications
  #
  getDefaultProps: ->
    cursor:
      user: UserStore.me()
      pins: PinStore.cursor.items
      pinboards: PinboardStore.cursor.items
      posts: PostStore.cursor.items


  getInitialState: ->
    ready: false


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch()

  # componentDidMount: ->
  # componentWillUnmount: ->

  conponentWillReceiveProps: (nextProps) ->
    fetch(nextProps.date) if nextProps.date and nextProps.date isnt @props.date


  # Helpers
  #
  getMainListCollection: ->
    result = new Array

    Object.keys(ObjectsForMainList).forEach (key) =>
      @state["#{key}_ids"].forEach (id) =>
        record = @props.cursor[key].get(id)

        result.push
          id: record.get('id')
          type: ObjectsForMainList[key]
          created_at: record.get('created_at')

    result


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  renderPlaceholders: ->
    <div className="">placeholders</div>

  renderMainList: ->
    Immutable.List(@getMainListCollection())
      .sortBy (object) -> object.created_at
      .reverse()
      .map (object, index) ->
        switch object.type
          when 'Pin'
            <section key={ index } className="cloud-column">
              <Insight pin = { object.id }/>
            </section>
          when 'Pinboard'
            <section key={ index } className="cloud-column">
              <Pinboard pinboard = { object.id } />
            </section>
      .toArray()

  renderFeaturedPosts: ->
    @state.featured_posts_ids.map (id, index) ->
      <section key={ index } className="cloud-column">
        <Post uuid = { id }/>
      </section>

  renderFeaturedPinboards: ->
    @state.featured_pinboards_ids.map (id, index) ->
      <section key={ index } className="cloud-column">
        <Pinboard pinboard = { id }/>
      </section>

  # Main render
  #
  render: ->
    return @renderPlaceholders() unless @state.ready

    <section className="cloud-columns cloud-columns-flex">
      <h2>Main list</h2>
      { @renderMainList() }
      <h2>Featured posts</h2>
      { @renderFeaturedPosts() }
      <h2>Featured pinboards</h2>
      { @renderFeaturedPinboards() }
    </section>
