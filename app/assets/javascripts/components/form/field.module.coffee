# @cjsx React.DOM

tag = React.DOM
cx = React.addons.classSet

MainComponent = React.createClass

  # Component specifications
  #
  propTypes:
    checked:      React.PropTypes.bool
    defaultValue: React.PropTypes.string
    errors:       React.PropTypes.array
    iconClass:    React.PropTypes.string
    syncing:      React.PropTypes.bool
    type:         React.PropTypes.string

    onBlur:       React.PropTypes.func
    onChange:     React.PropTypes.func
    onEnter:      React.PropTypes.func
    onFocus:      React.PropTypes.func
    onKeyDown:    React.PropTypes.func

  getDefaultProps: ->
    inputTag:     tag.input
    type:         "text"
    errors:       []
    defaultValue: ""
    iconClass:    ""

    checked:   false
    syncing:   false

    onChange:  ->
    onEnter:   ->
    onFocus:   ->
    onBlur:    ->
    onKeyDown: ->

  getInitialState: ->
    active: false

  # Helpers
  #
  isInvalid: ->
    @props.errors.length > 0

  # Handlers
  #
  handleChange: (event) -> @props.onChange(event)

  handleKeyDown: (event) -> 
    if event.keyCode == 13
      @props.onEnter()

    @props.onKeyDown(event)

  handleEnter: -> @props.onEnter()

  handleBlur: (event) -> 
    @props.onBlur(event)

    @setState(active: false)

  handleFocus: (event) -> 
    @props.onFocus(event)

    @setState(active: true)


  render: ->
    errors = if _.isArray(@props.errors) then @props.errors else [@props.errors]

    errors = _.map errors, (error, index) ->
      <span className="error" key={index}>{error}</span>

    customClass = {}
    customClass[@props.className] = true if @props.className

    Input = @props.inputTag

    <label className={cx(_.extend({
        "form-field-2": true
        invalid:        @isInvalid()
        checked:        @props.checked
        active:         @state.active
      }, customClass))}>

      {
        <span className="title">{@props.title}</span> if @props.title
      }
      
      <span className="input">

        <Input
          autoFocus    = { @props.autoFocus }
          defaultValue = { @props.defaultValue }
          name         = { @props.name }
          onChange     = { @onChange }
          onBlur       = { @onBlur }
          onFocus      = { @onFocus }
          onKeyDown    = { @onKeyDown }
          placeholder  = { @props.placeholder }
          ref          = "input"
          type         = { @props.type }
          value        = { @props.value } />
        
        {
          <span className="fa fa-check"></span> if @props.checked
        }

        {
          <i className="fa #{@props.iconClass}"></i> if @props.iconClass
        }
      </span>
      {
        errors
      }
    </label>

module.exports = MainComponent
