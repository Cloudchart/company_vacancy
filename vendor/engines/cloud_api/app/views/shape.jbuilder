shape = {
  fields: {
    full_name:    nil,
    avatar_url:   nil,
    roles:        {
      fields: {
        value:  nil,
        owner:  nil
      }
    },
    pinboards:    {
      fields: {
        title:    nil,
        pins: {
          fields: {
            content:  nil,
            user:     nil,
            parent: {
              fields: {
                content:  nil,
                user:     nil,
              }
            }
          }
        }
      }
    }
  }
}


json.shape CloudShape.shape(User.all, shape).as_json
