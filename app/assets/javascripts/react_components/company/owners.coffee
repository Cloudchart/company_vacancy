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

      .sortBy (invite) -> invite.full_name

      .map (invite) =>
        (tag.div { key: invite.uuid, className: 'controller aspect-ratio-1x1' },
          (tag.div { className: 'content' },
            (PersonComponent { key: invite.person_id })
            @gatherButtons(invite.uuid) unless @props.isReadOnly
          )
        )

      .value()

  gatherButtons: (invite) ->
    (tag.section { className: 'buttons' },
      (tag.button { 
        className: 'delete'
        value: invite
        onClick: @onCancelClick
      }, 
        'Cancel'
      )

      (tag.button { 
        className: 'change'
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
      url: "/company_invites/#{event.target.value}"
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
