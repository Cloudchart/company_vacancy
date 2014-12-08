# @cjsx React.DOM

tag = React.DOM
cx = React.addons.classSet

MainComponent = React.createClass

  isInvalid: ->
    @props.errors.length > 0

  onChange:  (event)  ->
    @props.onChange(event)

  onKeyDown: (event)  -> @props.onKeyDown(event)

  onBlur: (event) -> 
    @props.onBlur(event)

    @setState
      active: false

  onFocus: (event) -> 
    @props.onFocus(event)

    @setState
      active: true

  getDefaultProps: ->
    inputTag:     tag.input
    type:         "text"
    errors:       []
    defaultValue: ""

    checked:   false
    syncing:   false

    onChange:  ->
    onFocus:   ->
    onBlur:    ->
    onKeyDown: ->

  getInitialState: ->
    active: false

  render: ->
    errors = _.map @props.errors, (error, index) ->
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
        <span className="title">@props.title</span> if @props.title
      }
      
      <span className="input">

        <Input
          name         = {@props.valueName}
          onChange     = {@onChange}
          onBlur       = {@onBlur}
          onFocus      = {@onFocus}
          onKeyDown    = {@onKeyDown}
          placeholder  = {@props.placeholder}
          type         = {@props.type}
          value        = {@props.value} />
        
        {
          <span className="fa fa-check"></span> if @props.checked
        }

      </span>
      {
        errors
      }
    </label>

module.exports = MainComponent
