# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')
PinStore = require('stores/pin_store')
ParagraphStore = require('stores/paragraph_store.cursor')

Insight = require('components/cards/insight_card')
FeaturedPinboard = require('components/landing/featured_pinboard')
Pinboard = require('components/cards/pinboard_card')
Post = require('components/pinnable/post')
Paragraph = require('components/pinnable/block/paragraph')
ListOfCards = require('components/cards/list_of_cards')


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
        featuredPostsQuery        = """feed_featured_posts{#{Post.getQuery('post')}}"""
        featuredPinboardsQuery    = """feed_featured_pinboards{#{FeaturedPinboard.getQuery('pinboard')}}"""
        featuredParagraphsQuery   = """feed_featured_paragraphs"""

        """
          Viewer {
            feed_pins {
              #{Insight.getQuery('pin')}
            },
            feed_pinboards {
              #{Pinboard.getQuery('pinboard')}
            },
            #{featuredPinboardsQuery}
          }
        """

  # Fetchers
  #
  fetch: (date = @props.date) ->
    GlobalState.fetch(@getQuery('viewer'), { force: true, params: { date: @props.date } }).then (json) =>
      {
        feed_pins
        feed_pinboards
        feed_featured_posts
        feed_featured_pinboards
        feed_featured_paragraphs
      } = getFeedData(json.query)

      @setState
        ready:                    true
        pins_ids:                 feed_pins                 || []
        pinboards_ids:            feed_pinboards            || []
        featured_posts_ids:       feed_featured_posts       || []
        featured_pinboards_ids:   feed_featured_pinboards   || []
        featured_paragraphs_ids:  feed_featured_paragraphs  || []


  # Component Specifications
  #
  getDefaultProps: ->
    cursor:
      user:       UserStore.me()
      pins:       PinStore.cursor.items
      pinboards:  PinboardStore.cursor.items


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

  getFeedItems: ->
    feed_pinboards  = @state.pinboards_ids.map (id) -> Object.assign(PinboardStore.get(id).toJS(), type: 'Pinboard')
    feed_pins       = @state.pins_ids.map (id) -> Object.assign(PinStore.get(id).toJS(), type: 'Pin')

    Immutable.Seq(feed_pinboards.concat(feed_pins))
      .sortBy (record) -> record.created_at
      .reverse()
      .toArray()



  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  renderFeedItem: (item) ->

    switch item.type
      when 'Pin'
        <section key={ item.id } className="item">
          <Insight pin={ item.id } scope="feed" />
        </section>
      when 'Pinboard'
        <section key={ item.id } className="item">
          <Pinboard pinboard={ item.id } />
        </section>


  renderFeed: ->
    <section className="cc-container-common">
      <ListOfCards>
        { @getFeedItems().map(@renderFeedItem) }
      </ListOfCards>
    </section>


  renderFeaturedPinboard: (id) ->
    <FeaturedPinboard pinboard={ id } />


  renderFeaturedPinboards: ->
    @state.featured_pinboards_ids.map(@renderFeaturedPinboard)[0]


  renderFeaturedPosts: ->
    <section className="cc-container-common">
      <header>
        <h1>Featured Posts</h1>
      </header>
    </section>


  renderFeaturedParagraphs: ->
    <section className="cc-container-common">
      <header>
        <h1>Featured Paragraphs</h1>
      </header>
    </section>


  # Main render
  #
  render: ->
    return null unless @state.ready

    <div>
      { @renderFeed() }
      { @renderFeaturedPinboards() }
    </div>
