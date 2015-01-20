class PostSerializer < ActiveModel::Serializer

  attributes  :uuid, :title, :owner_id, :owner_type, :story_ids
  attributes  :created_at, :updated_at
  attributes  :effective_from, :effective_till, :position
  
  
  def story_ids
    object.stories.map(&:uuid)
  end
  

  def effective_from
    object.effective_from.try(:to_date)
  end

  def effective_till
    object.effective_till.try(:to_date)
  end

end
