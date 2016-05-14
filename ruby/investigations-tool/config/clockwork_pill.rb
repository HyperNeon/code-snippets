require /REDACTED/

class ClockworkPill
  def self.setup(app)
    # app here is the instance that is yielded to Bluepill.application, so you can add processes like
    app.process("clockwork_process") do |process|
      app_root = ENV['APP_ROOT']
      clockwork_path = 'bundle exec clockwork'
      rails_env = ENV['RAILS_ENV']
      process.pid_file = File.join(app_root, 'tmp', 'pids', 'clockwork_process.pid')
      process.working_dir = app_root
      process.daemonize = true

      process.start_command = "#{clockwork_path} #{app_root}/config/clockwork.rb"

      process.environment = {
        'RAILS_ENV' => rails_env,
        'APP_ROOT' => app_root
      }
      # Time to wait before starting to monitor the app. If the app takes longer
      # to start bluepill will attempt to monitor and will fail.
      process.start_grace_time = 15.seconds
      process.stop_grace_time = 15.seconds
      process.restart_grace_time = 20.seconds
    end
  end
end

Otf::Deployment::Pills.add_pill(ClockworkPill)