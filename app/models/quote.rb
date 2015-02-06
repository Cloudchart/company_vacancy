class Quote < ActiveRecord::Base
  include Uuidable
  
  belongs_to :person
  belongs_to :owner, polymorphic: true

  validates :text, presence: true

  def company
    if owner_type == "Block" 
      owner.company
    else
      nil
    end
  end
end
