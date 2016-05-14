require '/REDACTED/'
require "rvm/capistrano"

set :application, 'investigations-tool'

# SCM Setup
set :repository, 'git@/REDACTED/:/REDACTED/investigations-tool.git'
set :branch, fetch(:branch, "master")

# Ruby Version
set :rvm_ruby_string, 'ruby-2.0.0-p247'

# Cleanup releases
set :keep_releases, 3
after 'deploy:update', 'deploy:cleanup'
