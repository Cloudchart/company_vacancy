class CloudShapeTransformer < Parslet::Transform


  rule(fields: subtree(:fields)) do
    { fields: Array.wrap(fields).reduce({}, &:merge) }
  end


  rule(function: { name: simple(:name), value: simple(:value) }) do
    result = {}
    result[name.to_sym] = value.to_s
    result
  end


  rule(endpoint: subtree(:items)) do
    result        = {}
    name          = items[:name].to_sym

    data          = {}

    functions         = Array.wrap(items[:functions]).reduce({}, &:merge)
    data[:functions]  = functions unless functions.empty?

    fields        = Array.wrap(items[:fields]).reduce({}, &:merge)
    data[:fields] = fields unless fields.empty?

    result[name]  = data

    result
  end



end
