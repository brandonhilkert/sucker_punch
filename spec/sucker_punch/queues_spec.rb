require 'spec_helper'

describe SuckerPunch::Queues do
  describe "queue registration and querying" do
    after :all do
      SuckerPunch::Queues.instance_variable_set(:@queues, Set.new)
    end

    it "adds a queue to the master queue list" do
      SuckerPunch::Queues.register(:fake)
      expect(SuckerPunch::Queues.all).to eq([:fake])
    end
  end
end
