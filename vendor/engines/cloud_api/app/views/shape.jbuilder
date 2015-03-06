#json.set! :unicorns, CloudShape.shape(User.all, :full_name, pinboards: [:title, pins: :user], readable_pinboards: [:title, pins: :user])

shape = {
  fields: {
    id:           nil,
    full_name:    nil,
    avatar_url:   nil,
    # pinboards:    {
    #   fields: {
    #     id:       nil,
    #     title:    nil,
    #     pins: {
    #       fields: {
    #         id:       nil,
    #         content:  nil
    #       }
    #     }
    #   }
    # }
  }
}

json.set! :unicorns, CloudShape.shape(User.all, shape)
