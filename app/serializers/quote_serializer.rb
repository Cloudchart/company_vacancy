class QuoteSerializer < ActiveModel::Serializer
  attributes  :uuid, :owner_id, :owner_type
  attributes  :text, :person_id
  attributes  :created_at, :updated_at
end
