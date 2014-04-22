set   :deploy_to,     '~/apps/cloudchart_beta'
set   :branch,        'develop'

set   :linked_files,  fetch(:linked_files) + %w{config/environments/beta.rb}

set   :rbenv_ruby,    '2.1.1'

server 'hetzner', user: 'seanchas', roles: %w{app web db}
