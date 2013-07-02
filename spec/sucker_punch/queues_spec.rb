require 'spec_helper'

describe SuckerPunch::Queues do
  describe "queue registration and querying" do
    it "adds a queue to the master queue list" do
      SuckerPunch::Queues.register(:fake)
      expect(SuckerPunch::Queues.all).to eq([:fake])
    end
  end

  describe ".registered?" do
    it "returns true if queue has already been registered" do
      SuckerPunch::Queues.register(:fake)
      expect{ SuckerPunch::Queues.registered?(:fake) }.to be_true
    end
  end
end
