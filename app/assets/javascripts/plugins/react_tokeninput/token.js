// var React = require('react');
var span = React.DOM.span;
var li = React.DOM.li;

MainComponent = React.createClass({
  handleClick: function() {
    this.props.onRemove(this.props.value)
  },

  handleKeyDown: function(key) {
    var enterKey = 13;
    if(key.keyCode === enterKey) this.props.onRemove(this.props.value)
  },

  render: function() {
    return (
      li({
        className: "ic-token inline-flex"
      },
        span({className: "ic-token-label"}, this.props.name),
        span({
          role: 'button',
          onClick: this.handleClick,
          onKeyDown: this.handleKeyDown,
          'aria-label': 'Remove \'' + this.props.name + '\'',
          className: "ic-token-delete-button",
          tabIndex: 0
        }, "✕")
      )
    )
  }
})

cc.module('plugins/react_tokeninput/token').exports = MainComponent;
