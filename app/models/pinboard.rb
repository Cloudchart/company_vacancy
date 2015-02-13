class Pinboard < ActiveRecord::Base
  include Uuidable

  ACCESS_RIGHTS = [:piblic, :protected, :private]

  validates                 :title, presence: true
  validates_uniqueness_of   :title, scope: :user_id, case_sensitive: false

  belongs_to  :user
  has_many    :roles, as: :owner

  has_many    :pins
  has_many    :posts, through: :pins, source: :pinnable, source_type: Post


  # Roles on Users
  #
  { readers: [:reader, :editor], writers: :editor, followers: :follower }.each do |scope, role|
    has_many :"#{scope}_pinboards_roles", -> { where(value: role) }, as: :owner, class_name: Role
    has_many :"#{scope}", through: :"#{scope}_pinboards_roles", source: :user
  end


  scope :readable, -> do
    joins { roles.outer }.where { roles.value.eq('reader') }
  end


  scope :writable, -> do
    joins { roles.outer }.where { roles.value.eq('editor') }
  end

end
