class CloudShapeParser < Parslet::Parser


  rule(:endpoints) {
    (endpoint >> (comma >> endpoint).repeat).maybe.as(:fields)
  }


  rule(:endpoint) do
    (identifier.as(:name) >> functions.maybe >> children.maybe).as(:endpoint)
  end


  rule(:identifier) do
    match('[a-zA-Z]') >> match('[a-zA-Z0-9_]').repeat
  end


  rule(:functions) do
    (str('.') >> function).repeat.as(:functions)
  end


  rule(:function) do
    ((take_function | drop_function | sort_function).as(:name) >> str('(') >> value.maybe.as(:value) >> str(')')).as(:function)
  end


  [:take, :drop, :sort].each { |key| rule(:"#{key}_function") { str("#{key}") } }


  rule(:value) do
    match('[0-9a-zA-Z_]').repeat
  end


  rule(:children) do
    space >> str('{') >> endpoints.maybe >> str('}') >> space
  end


  rule(:comma) do
    space >> str(',') >> space
  end


  rule(:space) do
    match('[\s]').repeat
  end


  root(:endpoints)

end
