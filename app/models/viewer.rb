class Viewer < User


  def important_companies(scope = {})
    ability = Ability.new(scope[:current_user] || self)
    Company.important.select { |c| ability.can?(:read, c) }
  end



  def published_companies(scope = {})
    ability = scope[:current_user_ability] || Ability.new(scope[:current_user] || self)
    Company.published.select { |c| ability.can?(:read, c) }
  end


end
