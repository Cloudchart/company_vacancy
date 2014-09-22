class BurnRateChartSerializer < ActiveModel::Serializer
  attributes :uuid, :title, :slug, :should_display_table

  has_many :people, serializer: PersonSerializer

  def should_display_table
    object.people.pluck(:salary).uniq.sum > 0
  end

end
