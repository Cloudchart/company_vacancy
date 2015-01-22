# @cjsx React.DOM

cx = React.addons.classSet

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
    <div className="logo-and-name">
      { @renderLogo() }
      { @props.company.get('name') }
    </div>
  
  
  renderDate: ->
    date = moment(@props.company.get('established_on'))
    if date.isValid()
      <div className="date">{ date.format('ll') }</div>
  
  
  renderButtons: ->
    <ul className="buttons round-buttons">
      <li className="active" onClick={ @props.onUnpinClick }>
        <i className="fa fa-thumb-tack" />
      </li>
    </ul>
  
  
  # Main render
  #

  render: ->
    <header className="company">
      { @renderLogoAndName() }
      { @renderDate() }
      { @renderButtons() }
    </header>
