class ChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title, :permalink

  has_many :people_, serializer: PersonSerializer

end
