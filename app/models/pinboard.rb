class Pinboard < ActiveRecord::Base
  include Uuidable

  ACCESS_RIGHTS = [:piblic, :protected, :private]

  validates                 :title, presence: true
  validates_uniqueness_of   :title, scope: :user_id, case_sensitive: false

  belongs_to  :user
  has_many    :pins
  has_many    :roles, as: :owner


  scope :available, -> (user) do
    joins {

      roles.outer

    }.where {

      # user own
      (user_id.eq user.id) |

      # public
      ((access_rights.eq 'public') & ((user_id.not_eq user.uuid) | (user_id.eq nil))) |

      # available through roles
      ((roles.user_id == user.id) & (roles.value.in ['editor', 'reader']))

    }
  end


end
