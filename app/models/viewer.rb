class Viewer < User


  def important_companies(scope = {})
    Company.important.select { |c| ability(scope).can?(:read, c) }
  end


  def published_companies(scope = {})
    Company.published.select { |c| ability(scope).can?(:read, c) }
  end


  def important_pinboards(scope = {})
    Pinboard.important.select { |p| ability(scope).can?(:read, p) }
  end


  private

    def ability(scope = {})
      scope[:current_user_ability] ||= Ability.new(scope[:current_user] || self)
    end

end
