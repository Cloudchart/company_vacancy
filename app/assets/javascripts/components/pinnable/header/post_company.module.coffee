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

    <figure style={ backgroundImage: "url(#{url})" } />


  renderLogoAndTitle: ->
    classList = cx
      'logo-and-name':      true
      # 'has-name-in-logo':   @cursor.get('is_name_in_logo', false)

    <section className={ classList }>
      { @renderLogo() }
      { @cursor.get('name') }
    </section>


  render: ->
    return null unless @cursor.deref(false)

    <header className="company">
      { @renderLogoAndTitle() }
    </header>
