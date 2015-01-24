class Pinboard < ActiveRecord::Base
  include Uuidable

  validates :title, presence: true
  validates_uniqueness_of :title, scope: :user_id, case_sensitive: false
  
  belongs_to :user
  
  has_many :pins
  
  
  scope :general, -> { where(user_id: nil) }
  

  ACCESS_RIGHTS = [:piblic, :protected, :private]


  rails_admin do

    list do
      sort_by :title
      fields :title, :user, :created_at, :updated_at
    end

    edit do
      fields :title

      field :title do
        html_attributes do
          { autofocus: true }
        end
      end
    end

  end
end
