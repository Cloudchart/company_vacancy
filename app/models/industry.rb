class Industry < ActiveRecord::Base
  include Uuidable

  belongs_to :parent, class_name: 'Industry', foreign_key: :parent_id, inverse_of: :children
  has_and_belongs_to_many :companies
  has_many :children, -> { order(:name) }, class_name: 'Industry', foreign_key: :parent_id, inverse_of: :parent
  # has_paper_trail

  validates :name, presence: true

  scope :roots, -> { where(parent_id: nil).order(:name) }

  def is_root?
    parent_id.nil?
  end

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
