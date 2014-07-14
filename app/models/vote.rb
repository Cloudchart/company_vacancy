class Vote < ActiveRecord::Base
  include Uuidable

  after_save :sum_votes_for_destination

  belongs_to :source, polymorphic: true
  belongs_to :destination, polymorphic: true

  validates :value, presence: true

  scope :by_destination, -> destination_id { where(destination_id: destination_id) }
  scope :negative, -> { where('value < 0') }
  scope :positive, -> { where('value > 0') }

private

  def sum_votes_for_destination
    destination.update(votes_total: self.class.by_destination(destination_id).to_a.sum(&:value))
  end

end
