class ChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title, :permalink

  has_many :people, serializer: PersonSerializer

end
