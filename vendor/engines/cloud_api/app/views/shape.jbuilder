shape = CloudShapeTransformer.new.apply(CloudShapeParser.new.parse(params[:fields] || ''))

json.shape CloudShape.shape(User.first, shape).as_json
