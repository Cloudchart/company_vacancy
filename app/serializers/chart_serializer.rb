class ChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title

  has_many :people_, serializer: PersonSerializer

end
