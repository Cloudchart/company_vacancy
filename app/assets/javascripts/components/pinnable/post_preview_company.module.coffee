# @cjsx React.DOM

cx = React.addons.classSet

PinButton = require('components/pinnable/pin_button')

# Exports
#
module.exports = React.createClass


  # Renders
  #

  renderLogo: ->
    if source = @props.company.get('logotype_url')
      style =
        backgroundImage: "url(#{source})"
      <div className="logo" style={ style } />


  renderLogoAndName: ->
    classList = cx
      'logo-and-name':    true
      'has-name-in-logo': @props.company.get('is_name_in_logo')

    <div className={ classList }>
      { @renderLogo() }
      { @props.company.get('name') unless @props.company.get('is_name_in_logo') }
    </div>


  renderDate: ->
    date = moment(@props.pin.get('created_at'))
    if date.isValid()
      <div className="date">{ date.format('ll') }</div>


  renderButtons: ->
    <ul className="buttons round-buttons">
      <PinButton {...@props.pin.toJSON()} />
    </ul>


  # Main render
  #

  render: ->
    <header className="company">
      { @renderLogoAndName() }
      { @renderDate() }
      { @renderButtons() }
    </header>
