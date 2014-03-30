require 'spec_helper'

describe SuckerPunch::Queue do
  before :each do
    class ::FakeJob
      include SuckerPunch::Job

      def perform(name)
        "response #{name}"
      end
    end
  end

  after :each do
    Celluloid::Actor.clear_registry
  end

  describe "#find" do
    it "returns the Celluloid Actor from the registry" do
      SuckerPunch::Queue.new(FakeJob).register
      queue = SuckerPunch::Queue.find(FakeJob)
      queue.class == Celluloid::PoolManager
    end
  end

  describe "#register" do
    let(:job) { FakeJob }
    let(:queue) { SuckerPunch::Queue.new(job) }

    it "initializes a celluloid pool" do
      queue.register
      expect(queue.pool.class).to eq(Celluloid::PoolManager)
    end

    it "registers the pool with Celluloid" do
      pool = queue.register
      expect(Celluloid::Actor[:fake_job]).to eq(pool)
    end

    it "registers the pool with Celluloid and 3 workers" do
      pool = queue.register(3)
      expect(Celluloid::Actor[:fake_job].size).to eq(3)
    end

    context "when too many workers are specified" do
      it "raises a MaxWorkersExceeded exception" do
        expect{ queue.register(101) }.to raise_error(SuckerPunch::Queue::MaxWorkersExceeded)
      end
    end

    context "when too few workers are specified" do
      it "raises a NotEnoughWorkers exception" do
        expect{ queue.register(0) }.to raise_error(SuckerPunch::Queue::NotEnoughWorkers)
      end
    end
  end

  describe "#registered?" do
    it "returns true if queue has already been registered" do
      queue = SuckerPunch::Queue.new(FakeJob)

      expect{
        queue.register
      }.to change{ queue.registered? }.from(false).to(true)
    end
  end
end

