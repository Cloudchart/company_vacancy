module CloudGraph
  module Fields
    UserField = GraphQL::Field.new do |i, t, f, a|
      i.type CloudGraph::Types::UserType

      i.resolve -> (object, arguments, context) {
        ::User.find_by(twitter: 'seanchas')
      }
    end
  end
end
