module CloudBlueprint
  class Node < ActiveRecord::Base
    include Uuidable


    scope :later_then, -> (date) { where arel_table[:updated_at].gt(date) }


    belongs_to  :chart
    has_many    :children, foreign_key: :parent_id, class_name: Node.name


    def as_json_for_chart
      as_json(only: [:uuid, :chart_id, :parent_id, :title, :position])
    end
    

  end
end
