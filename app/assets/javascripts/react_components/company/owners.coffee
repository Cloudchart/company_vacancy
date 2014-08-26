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
          # @gatherButtons() unless @props.isReadOnly

          (OwnerSelectorComponent {
            filtered_people: @state.owners
          })
        )
      )
    )

  getInitialState: ->
    owners: @props.owners
    error: false
    sync: false

  getDefaultProps: ->
    isReadOnly: false

  # onChange: (event) ->
  #   @setState({ value: event.target.value })

  # onKeyUp: (event) ->
  #   switch event.key
  #     when 'Enter'
  #       @transferOwnership() if @isValid()
  #     when 'Escape'
  #       console.log 'Escape'

  gatherOwners: ->
    _.chain(@state.owners)

      .sortBy (owner) -> owner.first_name

      .map (owner) ->
        (tag.div { key: owner.uuid, className: 'controller aspect-ratio-1x1' },
          (tag.div { className: 'content' },
            (PersonComponent { key: owner.uuid })
          )
        )

      .value()

  # gatherButtons: ->
  #   (tag.section {
  #     className: 'buttons'
  #   },
  #     (tag.button { className: 'delete', onClick: @onDeleteClick }, 'Delete')
  #     (tag.button { ckassName: 'change', onClick: @onChangeClick }, 'Change')
  #   )

  # isValid: ->
  #   email_re.test(@state.value)

  # transferOwnership: ->
  #   @setState({ sync: true, error: false })

  #   $.ajax
  #     url: @props.transfer_ownership_url
  #     type: 'POST'
  #     dataType: 'json'
  #     data:
  #       email: @state.value
  #   .done @onTransferOwnershipDone
  #   .fail @onTransferOwnershipFail

  # onTransferOwnershipDone: ->
  #   @setState({ sync: false })
  #   console.log 'Done'

  # onTransferOwnershipFail: ->
  #   @setState({ sync: false, error: true })
  #   console.warn 'Fail'

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
