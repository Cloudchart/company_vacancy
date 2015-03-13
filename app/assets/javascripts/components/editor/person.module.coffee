# @cjsx React.DOM

# Imports
#
cx  = React.addons.classSet;


ModalStack    = require('components/modal_stack')

PersonStore   = require('stores/person')

PersonAvatar  = require('components/shared/person_avatar')
PersonForm    = require('components/form/person_form')


# Main
#
Person = React.createClass

  # Component specifications
  #
  propTypes:
    company_id:  React.PropTypes.string.isRequired
    onDelete:    React.PropTypes.func.isRequired
    readOnly:    React.PropTypes.bool
    uuid:        React.PropTypes.string.isRequired

  getDefaultProps: ->
    readOnly: true
  
  getInitialState: ->
    @getStateFromStores(@props)

  getStateFromStores: (props) ->
    person: PersonStore.get(props.uuid)

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  # Handlers
  #
  handleDelete: ->
    return if @props.readOnly

    @props.onDelete(@props.uuid)

  handlePersonClick: ->
    return if @props.readOnly
    
    ModalStack.show(
      <PersonForm
        attributes = { PersonStore.get(@props.uuid).toJSON() }
        onSubmit   = { -> ModalStack.hide() }
        uuid       = { @props.uuid } />
    )


  # Lifecycle methods
  #
  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  # Renderers
  #
  renderRemoveButton: ->
    return if @props.readOnly

    <i className="fa fa-times remove" onClick={ @handleDelete } />


  render: ->
    return null unless person = @state.person

    <div key={ person.uuid } className={cx({ person: true, editable: !@props.readOnly })}>
      { @renderRemoveButton() }
      
      <PersonAvatar
        value     = { person.full_name }
        avatarURL = { person.avatar_url }
        onClick   = { @handlePersonClick }
        readOnly  = { true }
      />
      
      <footer>
        <p className="name">{ person.full_name }</p>
        <p className="occupation">{ person.occupation }</p>
      </footer>
    </div>


# Exports
#
module.exports = Person
