class CompanyBurnRateSerializer < ActiveModel::Serializer
  attributes :established_on

  has_many :charts, serializer: BurnRateChartSerializer

end
