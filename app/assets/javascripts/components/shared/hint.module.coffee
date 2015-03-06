# @cjsx React.DOM
#

cx = React.addons.classSet

module.exports = React.createClass
  
  displayName: "Hint"

  # Component Specifications
  # 
  propTypes:
    content:  React.PropTypes.object
    opened:   React.PropTypes.bool
    visible:  React.PropTypes.bool

  getInitialState: ->
    opened:  false
    visible: true


  # Helpers
  #
  hideHint: ->
    @setState(opened: false)

  showHint: ->
    @setState(opened: true)


  # Handlers
  # 
  handleDocumentClick: (e) ->
    hintRef = @refs.hint

    if hintRef && $(e.target).closest(hintRef.getDOMNode()).length == 0
      @hideHint()

  handleClick: ->
    @setState(opened: !@state.opened)


  # Lifecycle Methods
  #   
  componentWillMount: ->
    if @props.visible
      $(document).on "click", @handleDocumentClick

      @setState
        opened: @props.opened

  componentWillReceiveProps: (nextProps) ->
    @setState 
      opened: nextProps.opened

  componentWillUnmount: ->
    if @props.visible
      $(document).off "click", @handleDocumentClick

  render: ->
    if @props.visible
      <aside ref="hint">
        <button 
          className    = "hint-button transparent"
          onClick      = {@handleClick}
          onMouseEnter = {@showHint}
          onMouseLeave = {@hideHint} >
          <i className="fa fa-question-circle"></i>
        </button>
        <div className={cx(hint: true, opened: @state.opened)}>
          { @props.content }
        </div>
      </aside>
    else
      null