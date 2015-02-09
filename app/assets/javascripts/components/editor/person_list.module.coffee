# @cjsx React.DOM

# Imports
#
cx  = React.addons.classSet;


CloudFlux         = require('cloud_flux')


ModalStack        = require('components/modal_stack')
PersonActions     = require('actions/person_actions')

PersonStore       = require('stores/person')

PersonPlaceholder = require('components/editor/person_placeholder')
Person            = require('components/editor/person')


# Main
#
PersonList = React.createClass

  # Component specifications
  #
  propTypes:
    company_id:  React.PropTypes.string.isRequired
    onAdd:       React.PropTypes.func.isRequired
    onDelete:    React.PropTypes.func.isRequired
    readOnly:    React.PropTypes.bool
    selected:    React.PropTypes.instanceOf(Immutable.Seq).isRequired

  getDefaultProps: ->
    readOnly: false
    selected: Immutable.Seq()
  
  getInitialState: ->
    _.extend @getStateFromStores(@props),
      animated: true
      hovered: false

  getStateFromStores: (props) ->
    setTimeout =>
      if @isMounted()
        @setState
          animated: true
    , 400

    peopleSeq = Immutable.Seq(PersonStore.filter((person) => props.selected.contains(person.uuid)))
    
    peopleSeq: peopleSeq
    animated:  false
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  # Helpers
  #
  getPeopleRows: ->
    @state.peopleSeq
      .sortBy((person) => @props.selected.indexOf(person.uuid))
      .reduce((memo, person, index, people) ->
        # form rows in groups of three
        if (lastRow = memo.slice(-1)[0]) && (lastRow.length < 3) && !(people.size % 3 == 1 && index == people.size - 2) # if the array has one element in the last group, add a previous one
          lastRow.push person
        else
          memo.push [person]

        memo
      , [])
  

  # Handlers
  #
  handleBeforeModalHide: ->
    if @isMounted() && !@props.readOnly
      @setState(hovered: false)

  handleBeforeModalShow: ->
    if @isMounted() && !@props.readOnly
      @setState(hovered: true)


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
  renderPlaceholder: ->
    <div key="placeholder" className="item placeholder">
      <PersonPlaceholder 
        company_id         = { @props.company_id }
        onSelect           = { @props.onAdd }
        onBeforeModalHide  = { @handleBeforeModalHide }
        onBeforeModalShow  = { @handleBeforeModalShow }
        selected           = { @props.selected } />
    </div>

  renderPeople: ->
    peopleRows = @getPeopleRows()

    if peopleRows.length > 0
      peopleRows.map (rows, index) =>
        <div key={index} className="row">
          {
            items = rows.map (person) =>
              <div className="item" key={ person.uuid }>
                <Person 
                  company_id = { @props.company_id }
                  onDelete   = { @props.onDelete }
                  readOnly   = { @props.readOnly }
                  uuid       = { person.uuid }  />
              </div>

            if !@props.readOnly && index == peopleRows.length - 1
              items.push @renderPlaceholder()

            items
          }
        </div>
    else if !@props.readOnly
      <div className="row">
        { @renderPlaceholder() }
      </div>
    else
      null


  render: ->
    classes = cx(
      "person-list": true
      hovered:       @state.hovered
      frozen:        @props.readOnly
      animated:      @state.animated
    )

    <div className = { classes }>
      { @renderPeople() }
    </div>


# Exports
#
module.exports = PersonList
