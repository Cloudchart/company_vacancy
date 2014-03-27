class Industry < ActiveRecord::Base
  include Uuidable

  belongs_to :parent, class_name: 'Industry', foreign_key: :parent_uuid, inverse_of: :children
  has_and_belongs_to_many :companies
  has_many :children, -> { order(:name) }, class_name: 'Industry', foreign_key: :parent_uuid, inverse_of: :parent

  validates :name, presence: true

  scope :roots, -> { where(parent_uuid: nil).order(:name) }

  rails_admin do
    list do
      exclude_fields :uuid, :children
    end

    edit do
      exclude_fields :uuid, :companies
    end

    show do
      exclude_fields :uuid
    end
  end  

end
