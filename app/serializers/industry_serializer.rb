class IndustrySerializer < ActiveModel::Serializer

  self.root = false
  
  attributes :uuid, :parent_id, :name
  
end
