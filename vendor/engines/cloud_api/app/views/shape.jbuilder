shape = {
  fields: {
    id:           nil,
    full_name:    nil,
    avatar_url:   nil,
    roles:        nil,
    # pinboards:    {
    #   fields: {
    #     id:       nil,
    #     title:    nil,
    #     pins: {
    #       fields: {
    #         id:       nil,
    #         content:  nil,
    #         user:     nil,
    #         parent: {
    #           fields: {
    #             id:       nil,
    #             content:  nil,
    #             user:     nil,
    #           }
    #         }
    #       }
    #     }
    #   }
    # }
  }
}

json.set! :count, User.unicorns.size
json.set! :unicorns, CloudShape.shape(User.unicorns, shape)
