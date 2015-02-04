class Pinboard < ActiveRecord::Base
  include Uuidable

  ACCESS_RIGHTS = [:piblic, :protected, :private]

  validates                 :title, presence: true
  validates_uniqueness_of   :title, scope: :user_id, case_sensitive: false

  belongs_to  :user
  has_many    :pins



  scope :belongs_to_user, -> (user) { arel_table[:user_id].eq user.uuid }
  scope :public_availability, -> (user) { arel_table[:user_id].eq(nil).or(arel_table[:user_id].not_eq(user.uuid)).and(arel_table[:access_rights].eq(:public)) }


  scope :available, -> (user) do
    where arel_table.grouping(public_availability(user)).or(belongs_to_user(user))
  end

end
