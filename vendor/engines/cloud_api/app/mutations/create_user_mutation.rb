class CreateUserMutation < CloudMutation

  expects :full_name, :avatar

  returns :user


  def execute!
    user = User.create! params

    {
      user: user
    }
  end


end
