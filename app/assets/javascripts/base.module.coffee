# Invite form
#
if (InviteButton = document.querySelector('[data-behaviour~="invite-button"]')) and (InviteForm = require('react_components/modals/invite_form'))
  ModalStack = require('components/modal_stack')

  InviteButton.addEventListener 'click', (event) ->
    event.preventDefault()

    ModalStack.show(InviteForm({}))

  InviteButton.click() if window.location.hash == '#invite'

#
#
_.each document.querySelectorAll('[data-react-class]'), (node) ->

  # TODO figure out how to catch errors later

  # try
    if !!node.dataset.reactClass
      reactClass  = require(node.dataset.reactClass)
      reactProps  = JSON.parse(node.dataset.reactProps) if node.dataset.reactProps

      React.renderComponent(reactClass(reactProps), node)

  # catch
  #   _.noop
