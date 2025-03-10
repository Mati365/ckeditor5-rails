# frozen_string_literal: true

# Puma configuration file

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development.
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch('PORT', 3002)

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', File.expand_path('tmp/pids/server.pid', File.dirname(__dir__)))

# Workers auto-scale between minimum and maximum
workers ENV.fetch('WEB_CONCURRENCY', 2)

# Use the `preload_app!` method when specifying a `workers` number.
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
