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
    uuid:      React.PropTypes.string
    post_id:   React.PropTypes.string
    type:      React.PropTypes.string
    withLinks: React.PropTypes.bool

  getDefaultProps: ->
    withLinks: true

  statics:

    queries:
      pin: ->
        """
          Post {
            company,
            pins {
              children
            }
          }
        """

      post: ->
        """
          Post {
            company 
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery(@props.type), { id: @props.post_id }).then =>
      @setState isLoaded: true


  # Helpers
  #
  isLoaded: ->
    @getPost().deref(false) || (@state && @state.isLoaded)

  getPin: ->
    if @props.type == 'pin'
      @cursor.pins.cursor(@props.uuid)
    else
      null

  getPost: ->
    post_id = if @props.type == 'pin'
      if (pinnable_id = @getPin().get('pinnable_id'))
        pinnable_id
      else
        repin = @cursor.pins.filter (pin) =>
          pin.get('parent_id') == @props.uuid
        .first()

        repin.get('pinnable_id') if repin
    else
      @props.post_id

    @cursor.posts.cursor(post_id)


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

    return null unless pin && post

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
    return null unless @isLoaded()

    <p className="quote">
      { @renderInsight() }
      { @renderInsightContext() }
    </p>

