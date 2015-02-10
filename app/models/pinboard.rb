class Pinboard < ActiveRecord::Base
  include Uuidable

  ACCESS_RIGHTS = [:piblic, :protected, :private]

  validates                 :title, presence: true
  validates_uniqueness_of   :title, scope: :user_id, case_sensitive: false

  belongs_to  :user
  has_many    :roles, as: :owner

  has_many    :pins
  has_many    :posts, through: :pins, source: :pinnable, source_type: Post

  sifter :user_own do |user|
    user_id.eq user.id
  end

  sifter :public do
    access_rights.eq 'public'
  end

  sifter :available_through_roles do |user, values|
    access_rights.not_eq('public') &
    roles.user_id.eq(user.id) &
    roles.value.in(values)
  end


  scope :writable, -> (user) do
    joins {

      roles.outer

    }.where {

      sift(:user_own, user) |
      sift(:available_through_roles, user, ['editor'])

    }.distinct
  end


  scope :readable, -> (user) do
    joins {

      roles.outer

    }.where {

      sift(:public) |
      sift(:user_own, user) |
      sift(:available_through_roles, user, ['editor', 'reader'])

    }.distinct
  end


end
