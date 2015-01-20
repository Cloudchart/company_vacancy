class PostSerializer < ActiveModel::Serializer

  attributes  :uuid, :title, :owner_id, :owner_type, :story_ids
  attributes  :created_at, :updated_at
  attributes  :effective_from, :effective_till, :position

  alias_method :current_user, :scope
  alias_method :post, :object

  def story_ids
    post.story_ids if current_user.is_admin?
  end

  def effective_from
    post.effective_from.try(:to_date)
  end

  def effective_till
    post.effective_till.try(:to_date)
  end

end
