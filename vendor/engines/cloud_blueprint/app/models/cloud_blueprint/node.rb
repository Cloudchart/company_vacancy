module CloudBlueprint
  class Node < ActiveRecord::Base

    include Uuidable


    scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }


    belongs_to  :chart
    has_many    :children, foreign_key: :parent_id, class_name: Node.name
    

    has_many    :identities, dependent: :destroy

    has_many    :people,    through: :identities, source: :identity, source_type: Person
    has_many    :vacancies, through: :identities, source: :identity, source_type: Vacancy


    def as_json_for_chart
      as_json(only: [:uuid, :chart_id, :parent_id, :title, :position, :knots])
    end

  end
end
