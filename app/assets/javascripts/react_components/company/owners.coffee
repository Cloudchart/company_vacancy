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
      (tag.header {}, 'Editors')
      (tag.div { className: 'section-block' },
        (tag.div { className: 'people' },
          @gatherOwners()
          @gatherInvites()
          # @gatherButtons() unless @props.isReadOnly

          (OwnerSelectorComponent {
            filtered_people: @state.owners.map (person) -> person.uuid
            onChange: @onOwnerSelectorChange
          })
        )
      )
    )

  getInitialState: ->
    owners: @props.owners
    owner_invites: @props.owner_invites
    error: false
    sync: false

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

            (tag.section { className: 'buttons' },
              (tag.button { className: 'delete', onClick: @onDeleteClick }, 'Delete')
              (tag.button { className: 'change', onClick: @onResendClick }, 'Resend')
            )
          )
        )

      .value()

  # Events
  # 
  onOwnerSelectorChange: (event) ->
    @setState(event.target.value)  

  onDeleteClick: (event) ->
    console.log 'onDeleteClick'

  onResendClick: (event) ->
    console.log 'onResendClick'

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
