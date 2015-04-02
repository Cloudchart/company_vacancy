module ControllerHelpers
  def sign_in(user = nil)
    user ||= create(:guest)

    allow(controller).to receive(:user_authenticated?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
