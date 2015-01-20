# @cjsx React.DOM
#

cx = React.addons.classSet

module.exports = React.createClass
  
  displayName: "Hint"

  # Component Specifications
  # 
  propTypes:
    text:       React.PropTypes.string
    opened:     React.PropTypes.bool

  getInitialState: ->
    opened: false

  # Handlers
  # 
  onDocumentClick: (e) ->
    hintNode = @refs.hint.getDOMNode()

    if $(e.target).closest(hintNode).length == 0
      @setState opened: false

  onClick: (props) ->
    @setState
      opened: !@state.opened

  # Lifecycle Methods
  #   
  componentWillMount: ->
    $(document).on "click", @onDocumentClick

    @setState
      opened: @props.opened

  componentWillReceiveProps: (nextProps) ->
    @setState 
      opened: nextProps.opened

  componentWillUnmount: ->
    $(document).off "click", @onDocumentClick

  render: ->
    <aside ref="hint">
      <button className="hint-button transparent" onClick={@onClick}>
        <i className="fa fa-question-circle"></i>
      </button>
      <div className={cx(hint: true, opened: @state.opened)}>
        { @props.text }
      </div>
    </aside>