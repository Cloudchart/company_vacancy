# @cjsx React.DOM

Logo = React.createClass

  propTypes:
    logoUrl: React.PropTypes.string

  render: ->
    if @props.logoUrl
      <img src={ @props.logoUrl }>
      </img>
    else
      null

module.exports = Logo
