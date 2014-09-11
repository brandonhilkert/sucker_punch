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
end
