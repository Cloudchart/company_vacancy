class UserNode < CloudRelay::Node


  exposes User


  attributes :id
  attributes :full_name
  attributes :company, :occupation
  attributes :avatar_url


  connection :pinboards, PinboardNode

end
