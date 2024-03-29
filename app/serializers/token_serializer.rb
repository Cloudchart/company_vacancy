class TokenSerializer < ActiveModel::Serializer

  self.root = false
  
  attributes :uuid, :name, :data, :owner_id, :owner_type, :rfc1751
  
  attributes :errors
  
  def rfc1751
    Cloudchart::RFC1751::encode(object.to_param)
  end
  
end
