@["cloud_profile/authentications#new"] = (data) ->
  LoginController = require("components/auth/login_controller")

  React.renderComponent(
    LoginController(), document.querySelector("body > main")
  )