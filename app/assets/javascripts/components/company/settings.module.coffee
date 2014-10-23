# @cjsx React.DOM

# Imports
#
tag = React.DOM

CompanyStore = require('stores/company')
CompanyActions = require('actions/company')

# UrlComponent = cc.require('components/company/settings/site_url')
Slug = require('components/company/settings/slug')
Progress = require('components/company/progress')
DateInput = require('cloud_blueprint/components/inputs/date_input')

# Main Component
#
Settings = React.createClass

  getStateFromStores: ->
    company: CompanyStore.get(@props.key)

  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)

  getInitialState: ->
    @getStateFromStores()

  onEstablishedOnChange: (value) ->
    CompanyActions.update(@props.key, { established_on: value }, 'established_on')

  # TODO looks hacky, need to figure out and rewrite DateInput
  formatDate: (date) ->
    if date instanceof Date then date else Date.parse(date)

  render: ->
    if @state.company

      <article className="editor settings">
        <section className="profile">
          <header>Profile</header>
          <div className="section-block">

            <div className="profile-item">
              <div className="content field">
                <label htmlFor="established_on">Established on</label>

                <div className="spacer"></div>

                <DateInput
                  id="established_on"
                  name="established_on"
                  date=@formatDate(@state.company.established_on)
                  placeholder="Jan 1, 2014"
                  onChange=@onEstablishedOnChange
                />
              </div>
            </div>

            <Slug key={@props.key} />

          </div>
        </section>

        <section className='progress'>
          <header>Progress</header>
          <Progress key={@props.key} />
        </section>
      </article>

    else
      null


# Exports
#
module.exports = Settings
