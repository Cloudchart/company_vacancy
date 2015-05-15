# @cjsx React.DOM
#

# components/hotzone.scss

module.exports = React.createClass
  
  displayName: "Hotzone"

  hide: ->
    @getDOMNode().style.display = 'none';

  componentDidMount: ->
    @getDOMNode().addEventListener('webkitAnimationEnd', @hide)

  componentDidUnmount: ->
    @getDOMNode().removeEventListener('webkitAnimationEnd', @hide)

  render: ->
    <div className="hotzone"></div>
