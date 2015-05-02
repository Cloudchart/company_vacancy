# @cjsx React.DOM

GlobalState = require('global_state/state')

# Stores
#
CompanyStore = require('stores/company_store.cursor')
PinStore     = require('stores/pin_store')
PostStore    = require('stores/post_store.cursor')


# Exports
#
module.exports = React.createClass

  displayName: 'PinnableInsight'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin_id:      React.PropTypes.string
    pinnable_id: React.PropTypes.string
    withLinks:   React.PropTypes.bool

  getDefaultProps: ->
    withLinks: true

  statics:

    queries:

      post: ->
        """
          Post {
            company 
          }
        """

  fetch: ->
    if @props.pinnable_id
      GlobalState.fetch(@getQuery('post'), { id: @props.pinnable_id }).then =>
        @setState isLoaded: true
    else
      @setState isLoaded: true


  # Helpers
  #
  isLoaded: ->
    @state && @state.isLoaded

  getPin: ->
    @cursor.pins.cursor(@props.pin_id) if @props.pin_id

  getPost: ->
    @cursor.posts.cursor(@props.pinnable_id) if @props.pinnable_id


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      pins:      PinStore.cursor.items
      companies: CompanyStore.cursor.items
      posts:     PostStore.cursor.items

    @fetch() unless @isLoaded()

  renderInsight: ->
    pin     = @getPin()
    post    = @getPost()

    return null unless pin

    if post
      if @props.withLinks
        <span>
          <a href={ post.get('post_url') } className="content" >
            <span dangerouslySetInnerHTML={ __html: pin.get('content') } />
          </a>
          { " — " }
        </span>    
      else
        <span>
          <span className="content" dangerouslySetInnerHTML={ __html: pin.get('content') } />
          { " — " }
        </span>
    else
      <span className="content" dangerouslySetInnerHTML={ __html: pin.get('content') } />

  renderInsightContext: ->
    post    = @getPost()
    company = @cursor.companies.cursor(post.get('owner_id')) if post

    return null unless post && company

    if @props.withLinks
      <span>
        <a href= { company.get('company_url') } className="company">
          { company.get('name') }
        </a>
        <strong>, </strong> 
        <a href={ post.get('post_url') } className="post">
          { post.get('title') }
        </a>
      </span>
    else
      <span>
        <span className="company">{ company.get('name') }</span>
        <strong>, </strong> 
        <span className="post">{ post.get('title') }</span>
      </span>


  render: ->
    return null unless @isLoaded() && (@getPost() || @getPin())

    <p className="quote">
      { @renderInsight() }
      { @renderInsightContext() }
    </p>

