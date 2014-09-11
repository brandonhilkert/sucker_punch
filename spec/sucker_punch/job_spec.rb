require 'spec_helper'

describe SuckerPunch::Job do
  before :each do
    class ::FakeJob
      include SuckerPunch::Job
      workers 4

      def perform(name)
        "response #{name}"
      end
    end
  end

  after :each do
    Celluloid::Actor.clear_registry
  end

  it "includes Celluloid into requesting class when included" do
    expect(FakeJob).to respond_to(:pool)
  end

  it "sets the pool size to 4" do
    pool = FakeJob.new
    expect(pool.size).to eq(4)
  end

  it "returns the same pool on each instantiation" do
    pool = FakeJob.new
    pool2 = FakeJob.new
    expect(pool.thread).to eq(pool2.thread)
  end

  describe "when pool hasn't been created" do
    it "registers queue" do
      queue = double("queue")
      allow(SuckerPunch::Queue).to receive(:new).and_return(queue)
      expect(queue).to receive(:register){ 4 }
      pool = FakeJob.new
    end
  end
end
