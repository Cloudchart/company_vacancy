# @cjsx React.DOM

# Imports
#
tag = React.DOM

CompanyStore   = require("stores/company")
CompanyActions = require("actions/company")

DateInput = require("cloud_blueprint/components/inputs/date_input")
Progress  = require("components/company/progress")
SiteUrl   = require("components/company/settings/site_url")
Slug      = require("components/company/settings/slug")

# Main Component
#
Settings = React.createClass

  # Helpers
  # 
  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)

  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  # TODO looks hacky, need to figure out and rewrite DateInput
  formatDate: (date) ->
    if date instanceof Date then date else Date.parse(date)

  # Handlers
  # 
  onEstablishedOnChange: (value) ->
    CompanyActions.update(@props.uuid, { established_on: value }, "established_on")

  # Lifecycle Methods
  # 
  componentDidMount: ->
    CompanyStore.on("change", @refreshStateFromStores)
  
  componentWillUnmount: ->
    CompanyStore.off("change", @refreshStateFromStores)

  # Component specifications
  #
  getInitialState: ->
    @getStateFromStores()

  render: ->
    if @state.company

      <article className="editor settings">
        <section className="profile">
          <header>Profile</header>
          <div className="section-block">

            <SiteUrl uuid={@props.uuid} />
            <Slug key={@props.uuid} />

            <div className="profile-item">
              <div className="content field">
                <label htmlFor="established_on">Established on</label>

                <div className="spacer"></div>

                <DateInput
                  id          = "established_on"
                  name        = "established_on"
                  date        = @formatDate(@state.company.established_on)
                  placeholder = "Jan 1, 2014"
                  onChange    = @onEstablishedOnChange
                />
              </div>
            </div>

          </div>
        </section>

        <section className="progress">
          <header>Progress</header>
          <Progress uuid={@props.uuid} />
        </section>
      </article>

    else
      null


# Exports
#
module.exports = Settings
