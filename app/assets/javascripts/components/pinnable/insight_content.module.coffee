# @cjsx React.DOM

# Stores
#
CompanyStore = require('stores/company_store.cursor')
PinStore     = require('stores/pin_store')
PostStore    = require('stores/post_store.cursor')


# Exports
#
module.exports = React.createClass

  displayName: 'PinnableInsight'

  propTypes:
    uuid: React.PropTypes.string.isRequired

  # Helpers
  #
  isLoaded: ->
    @cursor.pin.deref(false)

  getPost: ->
    post_id = if @cursor.pin.get('pinnable_id')
      @cursor.pin.get('pinnable_id')
    else
      repin = @cursor.pins.filter (pin) =>
        pin.get('parent_id') == @props.uuid
      .first()

      repin.get('pinnable_id') if repin

    @cursor.posts.cursor(post_id)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      pin:       PinStore.cursor.items.cursor(@props.uuid)
      pins:      PinStore.cursor.items
      companies: CompanyStore.cursor.items
      posts:     PostStore.cursor.items

  renderInsightContext: ->
    post    = @getPost()
    company = @cursor.companies.cursor(post.get('owner_id')) if post

    return null unless post && company

    <span>
      { " — " }
      <a href= { company.get('company_url') } className="company">
        { company.get('name') }
      </a>
      <strong>, </strong> 
      <a href={ post.get('post_url') } className="post">
        { post.get('title') }
      </a>
    </span>


  render: ->
    return null unless @isLoaded()

    <p className="quote">
      <span dangerouslySetInnerHTML={ __html: @cursor.pin.get('content') } />
      { @renderInsightContext() }
    </p>

