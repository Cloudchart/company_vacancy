module CloudGraph
  module Types

    UserType = GraphQL::ObjectType.new do |my, t, f|

      my.name "User"

      my.fields({

        id:           f.build(type: !t.String),
        first_name:   f.build(type: !t.String),
        last_name:    f.build(type: !t.String),
        twitter:      f.build(type: !t.String),

        pins:         f.build(type: -> { t[PinType] }),

        full_name:    GraphQL::Field.new { |my, t|
          my.type t.String
          my.resolve lambda { |root, a, c| [root.first_name, root.last_name].compact.join(' ') }
        }

      })

    end

  end
end
