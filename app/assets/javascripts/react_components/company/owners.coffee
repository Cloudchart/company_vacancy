##= require components/Person
##= require ./owners/selector

# Imports
# 
tag = React.DOM

PersonComponent = cc.require('cc.components.Person')
OwnerSelectorComponent = cc.require('react/company/owners/selector')

# Main Component
#
Component = React.createClass

  # Component Specifications
  #
  render: ->
    (tag.section {},
      (tag.header {}, 'Owners')
      (tag.div { className: 'section-block' },
        (tag.div { className: 'people' },
          @gatherOwners()
          @gatherInvites()

          (OwnerSelectorComponent {
            filtered_people: @filteredPeople()
            onChange: @onOwnerSelectorChange
          })
        )
      )
    )

  getInitialState: ->
    owners: @props.owners
    owner_invites: @props.owner_invites
    # error: false
    # sync: false

  getDefaultProps: ->
    isReadOnly: false

  # Instance methods
  # 
  gatherOwners: ->
    _.chain(@state.owners)

      .sortBy (owner) -> [owner.first_name, owner.last_name]

      .map (owner) ->
        (tag.div { key: owner.uuid, className: 'controller aspect-ratio-1x1' },
          (tag.div { className: 'content' },
            (PersonComponent { key: owner.uuid })
          )
        )

      .value()

  gatherInvites: ->
    _.chain(@state.owner_invites)

      .sortBy (person) -> [person.first_name, person.last_name]

      .map (person) =>
        (tag.div { key: person.uuid, className: 'controller aspect-ratio-1x1' },
          (tag.div { className: 'content' },
            (PersonComponent { key: person.uuid })
            @gatherButtons(person.uuid) unless @props.isReadOnly
          )
        )

      .value()

  gatherButtons: (key) ->
    (tag.section { className: 'buttons' },
      (tag.button { 
        className: 'delete'
        value: key
        onClick: @onCancelClick
      }, 
        'Cancel'
      )

      (tag.button { 
        className: 'change'
        value: key
        onClick: @onResendClick
      }, 
        'Resend'
      )
    )

  filteredPeople: -> 
    _.union(
      @state.owners.map((person) -> person.uuid), 
      @state.owner_invites.map((person) -> person.uuid)
    )

  # Events
  # 
  onOwnerSelectorChange: (event) ->
    @setState(event.target.value)  

  onCancelClick: (event) ->
    $.ajax
      url: "/people/#{event.target.value}/cancel_owner_invite"
      method: 'DELETE'
      dataType: 'json'
    .done @onCancelClickDone
    .fail @onCancelClickFail

  onCancelClickDone: (json) ->
    @setState(json)

  onCancelClickFail: ->
    console.warn 'onCancelClickFail'

  onResendClick: (event) ->
    alert 'Not implemented'

  # Lifecycle Methods
  #
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

# Exports
#
cc.module('react/company/owners').exports = Component
