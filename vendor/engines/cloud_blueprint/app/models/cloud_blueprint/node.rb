module CloudBlueprint
  class Node < ActiveRecord::Base

    include Uuidable
    

    def self.color_indices
      [
        "hsl(  0,  0%, 73%)",
        "hsl( 41, 88%, 68%)",
        "hsl(139, 51%, 59%)",
        "hsl(195, 92%, 67%)",
        "hsl( 20, 92%, 65%)",
        "hsl(247, 41%, 76%)",
        "hsl(347, 93%, 77%)"
      ]
    end


    scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }


    belongs_to  :chart
    has_many    :children, foreign_key: :parent_id, class_name: Node.name
    

    has_many    :identities, dependent: :destroy

    has_many    :people,    through: :identities, source: :identity, source_type: Person
    has_many    :vacancies, through: :identities, source: :identity, source_type: Vacancy


    def as_json_for_chart
      as_json(only: [:uuid, :chart_id, :parent_id, :title, :position, :color_index, :knots])
    end

  end
end
