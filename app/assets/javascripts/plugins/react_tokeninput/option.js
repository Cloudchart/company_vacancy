//= require ./add-class

var addClass = cc.require('plugins/react_tokeninput/add-class');
var li = React.DOM.li;

MainComponent = React.createClass({

  propTypes: {
    /**
     * The value that will be sent to the `onSelect` handler of the
     * parent Combobox.
    */
    value: React.PropTypes.any.isRequired,

    /**
     * What value to put into the input element when this option is
     * selected, defaults to its children coerced to a string.
    */
    label: React.PropTypes.string
  },

  getDefaultProps: function() {
    return {
      role: 'option',
      tabIndex: '-1',
      className: 'ic-tokeninput-option',
      isSelected: false
    };
  },

  render: function() {
    var props = this.props;
    if (props.isSelected) {
      props.className = addClass(props.className, 'ic-tokeninput-selected');
      props.ariaSelected = true;
    }
    return li(props);
  }

});

cc.module('plugins/react_tokeninput/option').exports = MainComponent;
