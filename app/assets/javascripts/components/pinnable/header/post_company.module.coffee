# @cjsx React.DOM


# Stores
#
CompanyStore = require('stores/company_store.cursor')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass


  displayName: 'PinnablePostCompanyHeader'


  componentWillMount: ->
    @cursor = CompanyStore.cursor.items.cursor(@props.uuid)


  renderLogo: ->
    return null unless url = @cursor.get('logotype_url', false)

    <img src={ url } />

  renderLogoAndTitle: ->
    <figure>
      { @renderLogo() }
      { @cursor.get('name') }
    </figure>


  render: ->
    return null unless @cursor.deref(false)

    @renderLogoAndTitle()