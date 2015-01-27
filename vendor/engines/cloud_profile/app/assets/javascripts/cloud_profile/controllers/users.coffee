@["cloud_profile/users#new"] = (data) ->
  RegisterController = require("components/auth/register_controller")

  React.renderComponent(
    RegisterController({invite: data.invite}), document.querySelector("body > main")
  )