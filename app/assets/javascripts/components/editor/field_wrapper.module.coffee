# @cjsx React.DOM
#

module.exports = React.createClass
  
  displayName: "FieldWrapper"

  render: ->
    <div className="editor-field-wrapper">
      { @props.children }
    </div>