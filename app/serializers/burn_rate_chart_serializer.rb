class BurnRateChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title, :slug, :created_at

  has_many :people, serializer: PersonSerializer

end
