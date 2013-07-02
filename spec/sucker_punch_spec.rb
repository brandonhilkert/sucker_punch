require 'spec_helper'

describe SuckerPunch do
  describe 'logger' do
    it "delegates get to Celluloid's logger" do
      SuckerPunch.logger.should == Celluloid.logger
    end

    it "delegates set to Celluloid's logger" do
      Celluloid.should_receive(:logger=)
      SuckerPunch.logger = nil
    end
  end
end
