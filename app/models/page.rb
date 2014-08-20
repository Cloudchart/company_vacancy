class Page < ActiveRecord::Base
  include Uuidable
  include Permalinkable

  has_paper_trail

  rails_admin do
    field :title
    field :body, :wysihtml5 do
      config_options html: true
    end
  end

end
