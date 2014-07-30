class TokenSerializer < ActiveModel::Serializer

  self.root = false
  
  attributes :uuid, :name, :data, :rfc1751
  
  def rfc1751
    Cloudchart::RFC1751::encode(object.to_param)
  end
  
end
