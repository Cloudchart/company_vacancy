@["cloud_profile/users#new"] = (data) ->
  RegisterForm = require("components/auth/register_form")

  React.renderComponent(
    RegisterForm({invite: data.invite}), document.querySelector("body > main")
  )