module Cloudchart

  class AdminConstraint
    def matches?(request)
      user_id = request.cookie_jar.signed[:user_id]
      user_id && User.find(user_id).try(:admin?)
    end
  end

end
