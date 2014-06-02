module CloudBlueprint
  class Identity < ActiveRecord::Base
    include Uuidable
    
    scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }


    belongs_to :chart, inverse_of: :identities
    belongs_to :node, inverse_of: :identities
    
    belongs_to :identity, polymorphic: true


    def as_json_for_chart
      as_json(only: [:uuid, :chart_id, :node_id, :identity_id, :identity_type, :is_primary])
    end

  end
end
