@["cloud_profile/passwords#reset"] = (data) ->
  PasswordResetForm = require("react_components/modals/password_reset_form")

  React.renderComponent(
    PasswordResetForm({token: data.token}), document.querySelector("body > main")
  )