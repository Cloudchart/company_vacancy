module CloudBlueprint
  class ChartSerializer < ActiveModel::Serializer
    
    attributes  :uuid
    attributes  :company_id
    attributes  :title
    attributes  :is_public
    attributes  :created_at, :updated_at
    
  end
end
