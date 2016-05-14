require 'rails_helper'

RSpec.describe RefreshAutomator do

  describe '.initialize' do
    it 'sets @@is_running to false' do
      expect(RefreshAutomator.new.is_running).to eq(false)
    end
  end

  describe '.run_main_loop' do
    let(:ra) {RefreshAutomator.new}

    it 'does nothing if @@is_running is true' do
      ra.is_running = true
      ra.expects(:refresh).never
      ra.run_main_loop
    end

    it 'calls refresh is @@is_running is false' do
      ra.expects(:refresh)
      ra.run_main_loop
    end
  end
end