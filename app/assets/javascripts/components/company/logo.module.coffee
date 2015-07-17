# @cjsx React.DOM

Logo = React.createClass

  propTypes:
    logoUrl: React.PropTypes.string

  render: ->
    if @props.logoUrl
      <figure style={ "background-image": "url(#{@props.logoUrl})" }  />
    else
      null

module.exports = Logo
