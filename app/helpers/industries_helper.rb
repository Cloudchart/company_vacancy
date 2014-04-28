module IndustriesHelper
  
  def full_industries_collection
    Industry.roots.includes(:children).inject([]) do |array, object|
      array.push [object.name, object.id]
      object.children.each { |child| array.push ['- ' + child.name, child.id] }
      array
    end
  end

  def companies_industries_collection
    Industry.joins(:companies).map { |object| [object.name, object.id ] }
  end

end
