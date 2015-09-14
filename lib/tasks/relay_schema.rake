namespace :relay do

  desc 'Generate GraphQL Relay Schema'

  task schema: :environment do
    File.open File.join(Rails.root, 'config', 'schema.json'), 'w' do |out|
      result = GraphQL::graphql(Schema::Schema, GraphQL::Introspection::Query)
      puts "RESULT: #{result}"
      out.write result.to_json
    end
  end

end
