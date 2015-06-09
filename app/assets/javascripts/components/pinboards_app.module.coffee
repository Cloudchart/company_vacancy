# @cjsx React.DOM


# Components
#
UserPinboards  = require('components/pinboards/lists/user')
StandardButton = require('components/form/buttons').StandardButton

NewPinboard    = require('components/pinboards/new_pinboard')

ModalStack     = require('components/modal_stack')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  propTypes:
    user_id: React.PropTypes.string.isRequired


  handleCreateCollectionClick: ->
    ModalStack.show(
      <NewPinboard user_id = { @props.user_id } />
    )

  render: ->
    <section className="pinboards-wrapper">
      <header className="cloud-columns cloud-columns-flex">
        Your collections
        <StandardButton
          className = "cc"
          onClick   = { @handleCreateCollectionClick }
          text      = "Create collection" />
      </header>
      <UserPinboards user_id = { @props.user_id } showPrivate = { true } />
    </section>