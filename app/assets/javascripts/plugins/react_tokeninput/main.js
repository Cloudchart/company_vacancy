//= require ./combobox
//= require ./token

var Combobox = cc.require('plugins/react_tokeninput/combobox');
var Token = cc.require('plugins/react_tokeninput/token');
var ul = React.DOM.ul;
var li = React.DOM.li;

MainComponent = React.createClass({
  propTypes: {
    onInput: React.PropTypes.func,
    onSelect: React.PropTypes.func.isRequired,
    onRemove: React.PropTypes.func.isRequired,
    selected: React.PropTypes.array.isRequired,
    menuContent: React.PropTypes.any
  },

  getInitialState: function() {
    return {
      selectedToken: null
    };
  },

  handleClick: function() {
    // TODO: Expand combobox API for focus
    this.refs['combo-li'].getDOMNode().querySelector('input').focus();
  },

  handleInput: function(event) {
    this.props.onInput(event);
  },

  handleSelect: function(event) {
    this.props.onSelect(event)
    this.setState({
      selectedToken: null
    })
  },

  handleRemove: function(value) {
    this.props.onRemove(value);
    this.refs['combo-li'].getDOMNode().querySelector('input').focus();
  },

  handleRemoveLast: function() {
    this.props.onRemove(this.props.selected[this.props.selected.length - 1]);
  },

  render: function() {
    var tokens = this.props.selected.map(function(token) {
      return (
        Token({
          onRemove: this.handleRemove,
          value: token,
          name: token.name,
          key: token.id})
      )
    }.bind(this))

    return ul({className: 'ic-tokens flex', onClick: this.handleClick},
      tokens,
      li({className: 'inline-flex', ref: 'combo-li'},
        Combobox({
          id: this.props.id,
          'aria-label': this.props['combobox-aria-label'],
          onInput: this.handleInput,
          onSelect: this.handleSelect,
          onRemoveLast: this.handleRemoveLast,
          value: this.state.selectedToken
        },
          this.props.menuContent
        )
      )
    );
  }
})

cc.module('plugins/react_tokeninput/main').exports = MainComponent;
