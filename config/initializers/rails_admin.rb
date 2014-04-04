RailsAdmin.config do |config|
  config.main_app_name = ['CloudChart', 'Admin']
  config.included_models = ['Company', 'Feature', 'User', 'Industry']

  config.authenticate_with do
    authenticate_user
  end
  config.current_user_method(&:current_user)

  config.authorize_with :cancan
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  # https://github.com/sferik/rails_admin/wiki/Actions
  config.actions do
    dashboard # mandatory
    index # mandatory
    new do
      except ['Company']
    end
    export
    bulk_delete
    show do
      except ['Feature']
    end
    edit
    delete
    show_in_app
    history_index do
      except ['Industry']
    end
    history_show do
      except ['Industry']
    end
  end
  
end
