# @cjsx React.DOM


# Components
#
PinboardSettings = require('components/pinboards/settings')
PinboardPins     = require('components/pinboards/pins/pinboard')
PinboardTabs     = require('components/pinboards/tabs')



# Exports
#
module.exports = React.createClass

  displayName: 'PinboardApp'

  propTypes:
    uuid: React.PropTypes.string.isRequired

  getInitialState: ->
    uuid:       @props.uuid
    currentTab: null


  handleTabChange: (tab) ->
    @setState currentTab: tab


  renderContent: ->
    switch @state.currentTab
      when 'insights'
        <PinboardPins pinboard_id = { @props.uuid } />
      when 'settings'
        <PinboardSettings uuid = { @props.uuid } />
      else
        null

  render: ->
    <section className="pinboards-wrapper">
      <PinboardTabs onChange = { @handleTabChange } />
      { @renderContent() }
    </section>