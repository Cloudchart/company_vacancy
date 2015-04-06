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


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      pin:       PinStore.cursor.items.cursor(@props.uuid)
      companies: CompanyStore.cursor.items
      posts:     PostStore.cursor.items


  render: ->
    return null unless @isLoaded()

    post    = @cursor.posts.cursor(@cursor.pin.get('pinnable_id'))
    company = @cursor.companies.cursor(post.get('owner_id'))

    <p className="quote">
      <span dangerouslySetInnerHTML={ __html: @cursor.pin.get('content') } />
      { " — " }
      <a href= { company.get('company_url') } className="company">
        { company.get('name') }
      </a>
      <strong>, </strong> 
      <a href={ post.get('post_url') } className="post">
        { post.get('title') }
      </a>
    </p>

