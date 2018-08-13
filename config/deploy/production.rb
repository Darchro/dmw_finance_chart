set :default_env, { path: "/usr/local/bin:$PATH" }

set :deploy_to, '/opt/www/dmw_finance'
set :branch, 'master'

set :puma_bind, %w(unix:///opt/www/dmw_finance/shared/tmp/sockets/puma.sock)
set :puma_threads, [1,8]
set :puma_workers, 1
set :puma_preload_app, false

set :nginx_sites_available_path, '/opt/nginx/sites-available'
set :nginx_sites_enabled_path, '/opt/nginx/sites-enabled'

server '118.25.216.205', user: 'root', roles: %w{app web}
