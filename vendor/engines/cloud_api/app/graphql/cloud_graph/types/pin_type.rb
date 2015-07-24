module CloudGraph
  module Types
    PinType = GraphQL::ObjectType.new do |my, t, f|

      my.name "Pin"

      my.fields({

        id:           f.build(type: !t.String),
        content:      f.build(type: !t.String),

        user:         f.build(type: -> { UserType }),

        parent:    GraphQL::Field.new { |my, t|
          my.type -> { PinType }
          my.resolve lambda { |root, a, c| root.parent }
        }

      })

    end
  end
end
