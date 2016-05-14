
require 'clockwork'
require_relative 'boot'
require_relative 'environment'

module Clockwork
  @@ra = RefreshAutomator.new

  @killed_file_path = Rails.root.join('log', 'it_automation_killed.lock')
  File.delete(@killed_file_path) if File.exist?(@killed_file_path)

  every(5.minutes, 'Refresh All Investigations', :thread => true) {
    begin
      @@ra.run_main_loop
    rescue => e
      Rails.logger.error "RECEIVED ERROR: #{e.message}\n\n#{e.backtrace.join("\n")}\n\n"

      Clockwork.write_error_file("Run Main Loop Failed", e)

    end
  }

  module_function

  def write_error_file(operation, error)
    File.open( @killed_file_path, 'a') do |f|
      error_hash = {:failed_operation => operation, :details => {:time => Time.now, :error => error.message, :stacktrace => error.backtrace.join("\n")}}
      f.puts error_hash.to_json
    end
  end
end