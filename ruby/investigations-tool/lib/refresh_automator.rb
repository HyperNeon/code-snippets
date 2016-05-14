class RefreshAutomator

  cattr_accessor :is_running

  # The main loop will not be running since we're initialized at launch
  def initialize
    @@is_running = false
  end

  # Runs each of the generation loops in order
  def run_main_loop
    # if @@is_running is true then the main loop is currently running so do nothing
    if @@is_running
      Rails.logger.info "CLOCKWORK: Main Loop Already Running - Skipping"
    else

      Rails.logger.info "Running Main Loop"
      @@is_running = true

      refresh

      Rails.logger.info "Finished Refreshing"

      # Reset variable at end of loop
      @@is_running = false
      Rails.logger.info "Finished Main Loop"
    end
  end

  def refresh
    Investigation.update_all_investigations
  end
end
