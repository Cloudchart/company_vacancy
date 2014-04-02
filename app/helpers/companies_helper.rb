module CompaniesHelper

  def attributes_for_droppable_article
    if can?(:update, Company)
      { :"data-behaviour" => 'droppable', :"data-droppable-target" => 'article' }
    else
      {}
    end
  end
  
end
