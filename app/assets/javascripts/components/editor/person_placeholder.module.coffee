# @cjsx React.DOM

# Imports
#
cx  = React.addons.classSet;

CloudFlux     = require('cloud_flux')

ModalStack    = require('components/modal_stack')

PersonChooser = require('components/editor/person_chooser')


# Main
#
PersonPlaceholder = React.createClass

  # Component specifications
  #
  propTypes:
    company_id:         React.PropTypes.string.isRequired
    onSelect:           React.PropTypes.func.isRequired
    onBeforeModalHide:  React.PropTypes.func
    onBeforeModalShow:  React.PropTypes.func
    selected:           React.PropTypes.instanceOf(Immutable.Seq).isRequired

  getDefaultProps: ->
    onBeforeModalHide: ->
    onBeforeModalShow:  ->


  # Handlers
  #
  handleSelect: (uuid) ->
    return if @props.readOnly

    @props.onSelect(uuid)
    ModalStack.hide()

  handleAddButtonClick: (event) ->
    return if @props.readOnly

    ModalStack.show(PersonChooser({
      company_id:     @props.company_id
      onSelect:       @handleSelect
      selected:       @props.selected
    }), {
      beforeShow:     @props.onBeforeModalShow
      beforeHide:     @props.onBeforeModalHide
    })


  render: ->
    <div className="person placeholder-wrapper editable">
      <figure className="avatar">
        <figcaption onClick={ @handleAddButtonClick }>
          <i className="cc-icon cc-plus" />
          <i className="hint">Add person</i>
        </figcaption>
      </figure>
    </div>


# Exports
#
module.exports = PersonPlaceholder
