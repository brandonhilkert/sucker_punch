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

    it "registers with master list of queues" do
      queue.register
      queues = SuckerPunch::Queues.all
      expect(queues.size).to be(1)
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

