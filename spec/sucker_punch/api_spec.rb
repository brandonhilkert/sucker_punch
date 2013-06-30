require 'spec_helper'

describe SuckerPunch::API::Queues do
  describe "queue registration and querying" do
    it "adds a queue to the master queue list" do
      SuckerPunch::API::Queues.register(:fake)
      expect(SuckerPunch::API::Queues.all).to eq([:fake])
    end
  end
end
