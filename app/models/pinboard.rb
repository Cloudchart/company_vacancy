class Pinboard < ActiveRecord::Base
  include Uuidable

  ACCESS_RIGHTS = [:public, :protected, :private].freeze
  INVITABLE_ROLES = [:editor, :reader, :follower].freeze

  validates :title, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :access_rights, presence: true, inclusion: { in: ACCESS_RIGHTS.map(&:to_s) }

  belongs_to :user

  has_many :pins
  has_many :roles, as: :owner
  has_many :posts, through: :pins, source: :pinnable, source_type: 'Post'
  has_many :users, through: :roles

  # Roles on Users
  #
  { readers: [:reader, :editor], writers: :editor, followers: :follower }.each do |scope, role|
    has_many :"#{scope}_pinboards_roles", -> { where(value: role) }, as: :owner, class_name: Role
    has_many :"#{scope}", through: :"#{scope}_pinboards_roles", source: :user
  end

  sifter :system do
    access_rights.eq('public') & user_id.eq(nil)
  end

  sifter :available_through_roles do |user, values|
    access_rights.not_eq('public') &
    roles.user_id.eq(user.id) &
    roles.value.in(values)
  end

  scope :system, -> do
    where access_rights: :public, user_id: nil
  end

  scope :readable, -> do
    joins { roles.outer }.where { roles.value.eq('reader') }
  end

  scope :writable, -> do
    joins { roles.outer }.where { roles.value.eq('editor') }
  end

end
