module UsersHelper
  def show_welcome_tour?
    current_user.tokens.find_by(name: :welcome_tour)
  end
end
