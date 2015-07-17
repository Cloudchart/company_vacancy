class CreateTourTokensForAllUnicorns < ActiveRecord::Migration
  def up
    User.includes(:tokens).unicorns.each do |unicorn| 
      %w(welcome_tour insight_tour).each do |token_name|
        unicorn.tokens.create(name: token_name) unless unicorn.tokens.map(&:name).include?(token_name)
      end
    end
  end

  def down
    say 'Nothing to be done'
  end
end
