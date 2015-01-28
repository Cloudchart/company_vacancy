@["cloud_profile/users#new"] = (data) ->
  SignupController = require("components/auth/signup_controller")

  React.renderComponent(
    SignupController({invite: data.invite, email: data.email}), document.querySelector("body > main")
  )