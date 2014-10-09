class BurnRateChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title, :slug

  has_many :people, serializer: PersonSerializer

end
