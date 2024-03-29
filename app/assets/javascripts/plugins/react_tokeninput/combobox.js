//= require ./add-class
//= require ./option

var guid = 0;
var k = function(){};
var addClass = cc.require('plugins/react_tokeninput/add-class');
var ComboboxOption = cc.require('plugins/react_tokeninput/option');
var div = React.DOM.div;
var span = React.DOM.span;
var input = React.DOM.input;
var ul = React.DOM.ul;
var i = React.DOM.i;
var cx = React.addons.classSet;

MainComponent = React.createClass({

  propTypes: {
    /**
     * Called when the combobox receives user input, this is your chance to
     * filter the data and rerender the options.
     *
     * Signature:
     *
     * ```js
     * function(userInput){}
     * ```
    */
    onInput: React.PropTypes.func,

    /**
     * Called when the combobox receives a selection. You probably want to reset
     * the options to the full list at this point.
     *
     * Signature:
     *
     * ```js
     * function(selectedValue){}
     * ```
    */
    onSelect: React.PropTypes.func,

    isDropdown: React.PropTypes.bool
  },

  getDefaultProps: function() {
    return {
      autocomplete: 'both',
      isDropdown: false,
      onInput: k,
      onSelect: k,
      value: null
    };
  },

  getInitialState: function() {
    return {
      value: this.props.value,
      // the value displayed in the input
      inputValue: this.findInitialInputValue(),
      isOpen: false,
      focusedIndex: null,
      focused: false,
      matchedAutocompleteOption: null,
      // this prevents crazy jumpiness since we focus options on mouseenter
      usingKeyboard: false,
      activedescendant: null,
      listId: 'ic-tokeninput-list-'+(++guid),
      menu: {
        children: [],
        activedescendant: null,
        isEmpty: true
      }
    };
  },

  componentWillMount: function() {
    this.setState({menu: this.makeMenu()});
  },

  componentWillReceiveProps: function(newProps) {
    this.setState({menu: this.makeMenu(newProps.children)});
  },

  /**
   * We don't create the <ComboboxOption> components, the user supplies them,
   * so before rendering we attach handlers to facilitate communication from
   * the ComboboxOption to the Combobox.
  */
  makeMenu: function(children) {
    var activedescendant;
    var isEmpty = true;
    children = children || this.props.children;
    React.Children.forEach(children, function(child, index) {
      if (child.type !== ComboboxOption.type)
        // allow random elements to live in this list
        return;
      isEmpty = false;
      // TODO: cloneWithProps and map instead of altering the children in-place
      var props = child.props;
      if (this.state.value === props.value) {
        // need an ID for WAI-ARIA
        props.id = props.id || 'ic-tokeninput-selected-'+(++guid);
        props.isSelected = true
        activedescendant = props.id;
      }
      props.onBlur = this.handleOptionBlur;
      props.onClick = this.selectOption.bind(this, child);
      props.onFocus = this.handleOptionFocus;
      props.onKeyDown = this.handleOptionKeyDown.bind(this, child);
      props.onMouseEnter = this.handleOptionMouseEnter.bind(this, index);
    }.bind(this));

    if(isEmpty) {
      this.hideList();
    }

    return {
      children: children,
      activedescendant: activedescendant,
      isEmpty: isEmpty
    };
  },

  getClassName: function() {
    var className = addClass(this.props.className, 'ic-tokeninput');
    if (this.state.isOpen)
      className = addClass(className, 'ic-tokeninput-is-open');
    return className;
  },

  /**
   * When the user begins typing again we need to clear out any state that has
   * to do with an existing or potential selection.
  */
  clearSelectedState: function(cb) {
    this.setState({
      focusedIndex: null,
      inputValue: null,
      value: null,
      matchedAutocompleteOption: null,
      activedescendant: null
    }, cb);
  },

  handleInputChange: function(event) {
    var value = this.refs.input.getDOMNode().value;
    this.clearSelectedState(function() {
      this.props.onInput(value);
      if (!this.state.isOpen)
        this.showList();
    }.bind(this));
  },

  handleClick: function() {
    this.showList();
  },

  handleInputBlur: function() {
    this.setState({ focused: false });
    var focusedAnOption = this.state.focusedIndex != null;
    if (focusedAnOption)
      return;
    this.maybeSelectAutocompletedOption();
    this.hideList();
  },

  handleInputFocus: function() {
    this.setState({ focused: true });
  },

  handleOptionBlur: function() {
    // don't want to hide the list if we focused another option
    this.blurTimer = setTimeout(this.hideList, 0);
  },

  handleOptionFocus: function() {
    // see `handleOptionBlur`
    clearTimeout(this.blurTimer);
  },

  handleInputKeyUp: function(event) {
    if (
      this.state.menu.isEmpty ||
      // autocompleting while backspacing feels super weird, so let's not
      event.keyCode === 8 /*backspace*/ ||
      !this.props.autocomplete.match(/both|inline/)
    ) return;
  },

  handleButtonClick: function() {
    this.state.isOpen ? this.hideList() : this.showList();
    this.focusInput();
  },

  showList: function() {
    this.setState({isOpen: true})
  },

  hideList: function() {
    this.setState({isOpen: false});
  },

  hideOnEscape: function(event) {
    if (this.state.isOpen) {
      this.hideList();
      this.focusInput();
    } else if (this.refs.input.getDOMNode().value) { // added
      this.refs.input.getDOMNode().value = '' // added
    } else {
      this.blurInput();
    }

    // check if the first argument is actually a child
    // for hacky component hacky fixes
    if (typeof event.preventDefault != 'function') {
      event = arguments[1]
    }

    event.preventDefault();
    event.stopPropagation();
  },

  focusInput: function() {
    this.refs.input.getDOMNode().focus();
  },

  blurInput: function() {
    this.refs.input.getDOMNode().blur();
  },

  selectInput: function() {
    this.refs.input.getDOMNode().select();
  },

  inputKeydownMap: {
    // 8: 'removeLastToken', // added manual handler (cmd + backspace)
    13: 'selectOnEnter',
    27: 'hideOnEscape',
    38: 'focusPrevious',
    40: 'focusNext',
    188: 'selectOnEnter'
  },

  optionKeydownMap: {
    13: 'selectOption',
    27: 'hideOnEscape',
    38: 'focusPrevious',
    40: 'focusNext'
  },

  handleKeydown: function(event) {
    // removeLastToken on cmd + backspace
    if ((event.metaKey || event.ctrlKey) && event.key == 'Backspace') {
      this.setState({usingKeyboard: true});
      return this.removeLastToken.call(this, event);
    }

    var handlerName = this.inputKeydownMap[event.keyCode];
    if (!handlerName)
      return
    this.setState({usingKeyboard: true});
    return this[handlerName].call(this,event);
  },

  handleOptionKeyDown: function(child, event) {
    var handlerName = this.optionKeydownMap[event.keyCode];
    if (!handlerName) {
      // if the user starts typing again while focused on an option, move focus
      // to the inpute, select so it wipes out any existing value
      this.selectInput();
      return;
    }
    event.preventDefault();
    this.setState({usingKeyboard: true});
    this[handlerName].call(this, child, event);
  },

  handleOptionMouseEnter: function(index) {
    if (this.state.usingKeyboard)
      this.setState({usingKeyboard: false});
    else
      this.focusOptionAtIndex(index);
  },

  selectOnEnter: function(event) {
    event.preventDefault();
    this.maybeSelectAutocompletedOption()
  },

  maybeSelectAutocompletedOption: function() {
    if (!this.state.matchedAutocompleteOption) {
      this.selectText()
    } else {
      this.selectOption(this.state.matchedAutocompleteOption, {focus: false});
    }
  },

  selectOption: function(child, options) {
    options = options || {};
    this.setState({
      // value: child.props.value,
      // inputValue: getLabel(child),
      matchedAutocompleteOption: null
    }, function() {
      this.props.onSelect(child.props.value, child);
      this.hideList();
      this.clearSelectedState(); // added
      if (options.focus !== false)
        this.selectInput();
    }.bind(this));
    this.refs.input.getDOMNode().value = '' // added
  },

  selectText: function() {
    var value = this.refs.input.getDOMNode().value;
    if(!value) return;
    this.props.onSelect(value);
    this.clearSelectedState();
    this.refs.input.getDOMNode().value = '' // added
  },

  focusNext: function(event) {
    if(event.preventDefault) event.preventDefault();
    if (this.state.menu.isEmpty) return;
    var index = this.state.focusedIndex == null ?
      0 : this.state.focusedIndex + 1;
    this.focusOptionAtIndex(index);
  },

  removeLastToken: function() {
    if(this.props.onRemoveLast && !this.refs.input.getDOMNode().value) {
      this.props.onRemoveLast()
    }
    return true
  },

  focusPrevious: function(event) {
    if(event.preventDefault) event.preventDefault();
    if (this.state.menu.isEmpty) return;
    var last = this.props.children.length - 1;
    var index = this.state.focusedIndex == null ?
      last : this.state.focusedIndex - 1;
    this.focusOptionAtIndex(index);
  },

  focusSelectedOption: function() {
    var selectedIndex;
    React.Children.forEach(this.props.children, function(child, index) {
      if (child.props.value === this.state.value)
        selectedIndex = index;
    }.bind(this));
    this.showList();
    this.setState({
      focusedIndex: selectedIndex
    }, this.focusOption);
  },

  findInitialInputValue: function() {
    // TODO: might not need this, we should know this in `makeMenu`
    var inputValue;
    React.Children.forEach(this.props.children, function(child) {
      if (child.props.value === this.props.value)
        inputValue = getLabel(child);
    }.bind(this));
    return inputValue;
  },

  focusOptionAtIndex: function(index) {
    if (!this.state.isOpen && this.state.value)
      return this.focusSelectedOption();
    this.showList();
    var length = this.props.children.length;
    if (index === -1)
      index = length - 1;
    else if (index === length)
      index = 0;
    this.setState({
      focusedIndex: index
    }, this.focusOption);
  },

  focusOption: function() {
    var index = this.state.focusedIndex;
    this.refs.list.getDOMNode().childNodes[index].focus();
  },

  render: function() {
    var ariaLabel = this.props['aria-label'] || 'Start typing to search. ' +
      'Press the down arrow to navigate results. If you don\'t find an ' +
      'acceptable option, you can enter an alternative.'

    return div({
        className: this.getClassName(),
        style: {
          display:  'inline-block',
          maxWidth: '100%',
          width:    'auto',
        }
      },
      (div({
          ref:          'sizer',
          style: {
            height:     0,
            overflow:   'hidden',
            visibility: 'hidden',
            whiteSpace: 'pre'
          }
        },
        this.props.value || this.props.placeholder
      )),
      (this.props.isDropdown ? i({className: 'fa fa-angle-down', onClick: this.handleClick}) : null),
      input({
        ref: 'input',
        autoComplete: 'off',
        spellCheck: 'false',
        'aria-label': ariaLabel,
        'aria-expanded': this.state.isOpen+'',
        'aria-haspopup': 'true',
        'aria-activedescendant': this.state.menu.activedescendant,
        'aria-autocomplete': 'list',
        'aria-owns': this.state.listId,
        id: this.props.id,
        className: cx({ 'ic-tokeninput-input': true, 'active': this.state.focused }),
        onChange: this.handleInputChange,
        onClick: this.handleClick,
        onFocus: this.handleInputFocus,
        onBlur: this.handleInputBlur,
        onKeyDown: this.handleKeydown,
        onKeyUp: this.handleInputKeyUp,
        placeholder: this.props.placeholder,
        role: 'combobox',
        style: { width: '100%' }
      }),
      ul({
        id: this.state.listId,
        ref: 'list',
        className: 'ic-tokeninput-list',
        role: 'listbox'
      }, this.state.menu.children)
    );
  }
});

function getLabel(component) {
  return component.props.label || component.props.children;
}

function matchFragment(userInput, firstChildLabel) {
  userInput = userInput.toLowerCase();
  firstChildLabel = firstChildLabel.toLowerCase();
  if (userInput === '' || userInput === firstChildLabel)
    return false;
  if (firstChildLabel.toLowerCase().indexOf(userInput.toLowerCase()) === -1)
    return false;
  return true;
}

cc.module('plugins/react_tokeninput/combobox').exports = MainComponent;
