class Viewer < User


  def important_companies(scope = {})
    ability = Ability.new(scope[:current_user] || self)
    Company.important.select { |c| ability.can?(:read, c) }
  end


end
