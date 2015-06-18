# config valid only for Capistrano 3.1
lock '3.2.1'

set :application,   'cloudchart'
set :repo_url,      'git@github.com:Cloudchart/company_vacancy.git'
set :linked_files,  %w{config/database.yml config/secrets.yml .env}
set :linked_dirs,   %w{log tmp/pids tmp/cache tmp/sockets public/uploads public/system}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for keep_releases is 5
# set :keep_releases, 5

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end

#   after :publishing, :restart

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       within release_path do
#         # execute :rake, 'cache:clear'
#       end
#     end
#   end

  desc 'Generates static error pages in public folder'
  task :generate_error_pages do
    on roles :app do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rails, 'generate static_error_pages -f'
        end
      end
    end
  end

  desc 'Runs rake db:seed'
  task :seed do
    on roles :db do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:seed'
        end
      end
    end
  end

  after :publishing, :generate_error_pages

end

namespace :rails do
  desc 'Tails rails log'
  task :log do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:stage)}.log"
    end
  end

  desc 'Runs rails console'
  task :console do
    on roles(:app) do |host|
      exec "ssh #{fetch(:user)}@#{host} -t 'cd #{release_path} && #{fetch(:rbenv_prefix)} bundle exec rails c -e #{fetch(:stage)}'"
    end
  end

end

namespace :tire do
  desc 'Reindex elasticsaerch'
  task :import do
    on roles :app do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'environment tire:import:all FORCE=true'
        end
      end
    end
  end

end


namespace :cc do

  desc 'Calculate insights weights'
  task :calculate_insight_weight do
    on roles :app do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'cc:calculate_insight_weight'
        end
      end
    end
  end

end
