# @cjsx React.DOM
#

cx = React.addons.classSet

module.exports = React.createClass
  
  displayName: "Hint"

  # Component Specifications
  # 
  propTypes:
    customClass: React.PropTypes.string
    isHintable:  React.PropTypes.bool
    text:        React.PropTypes.string
    visible:     React.PropTypes.bool

  getDefaultProps: ->
    customClass:   ""
    isHintable:    false

  getInitialState: ->
    visible: false

  # Handlers
  # 
  onDocumentClick: (e) ->
    hintNode = @refs.hint.getDOMNode()

    if $(e.target).closest(hintNode).length == 0
      @setState visible: false

  onClick: (props) ->
    @setState
      visible: !@state.visible

  # Lifecycle Methods
  #   
  componentWillMount: ->
    if @props.isHintable
      $(document).on "click", @onDocumentClick

      @setState
        visible: @props.visible

  componentWillReceiveProps: (nextProps) ->
    if @props.isHintable
      @setState 
        visible: nextProps.visible

  componentWillUnmount: ->
    if @props.isHintable
      $(document).off "click", @onDocumentClick

  render: ->
    if @props.isHintable
      <div className={ "hintable #{@props.customClass}".trim() }>
        <aside ref="hint" className="hint-wrapper">
          <button className="transparent" onClick={@onClick}>
            <i className="fa fa-question-circle"></i>
          </button>
          <div className={cx(hint: true, visible: @state.visible)}>
            { @props.text }
          </div>
        </aside>
        { @props.children }
      </div>
    else
      @props.children