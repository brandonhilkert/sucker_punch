require 'spec_helper'

describe SuckerPunch do
  describe 'logger' do
    it "delegates get to Celluloid's logger" do
      expect(SuckerPunch.logger).to eq Celluloid.logger
    end

    it "delegates set to Celluloid's logger" do
      expect(Celluloid).to receive(:logger=)
      SuckerPunch.logger = nil
    end
  end

  describe '.clear_queues' do
    it "clears SuckerPunch queues" do
      allow(SuckerPunch::Queue).to receive(:clear_all)

      SuckerPunch.clear_queues

      expect(SuckerPunch::Queue).to have_received(:clear_all)
    end
  end
end
