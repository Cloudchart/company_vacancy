class BurnRateChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title, :slug#, :should_display_table

  has_many :people, serializer: PersonSerializer

  # WIP
  # def should_display_table
  #   object.people.pluck(:salary).flatten
  # end

end
