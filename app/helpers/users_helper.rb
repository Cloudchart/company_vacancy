module UsersHelper
  def show_tour?
    current_user.tokens.find_by(name: "tour")
  end
end
