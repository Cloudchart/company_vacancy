class Feature < ActiveRecord::Base
  include Uuidable

  has_many :votes, as: :destination, dependent: :destroy
  has_paper_trail

  validates :name, presence: true

  rails_admin do

    list do
      exclude_fields :uuid
    end

    edit do
      exclude_fields :uuid, :votes_total
    end

  end

end
