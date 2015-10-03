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

  describe ".find" do
    it "returns the Celluloid Actor from the registry" do
      SuckerPunch::Queue.new(FakeJob).register
      queue = SuckerPunch::Queue.find(FakeJob)
      expect(queue.class).to eq(Celluloid::Supervision::Container::Pool)
    end
  end

  describe ".clear_all" do
   it "removes SuckerPunch actors from Celluloid registry" do
     sucker_punch_actor_name = "#{SuckerPunch::Queue::REGISTRY_PREFIX}_fake_job".to_sym
     Celluloid::Actor[sucker_punch_actor_name] = FakeJob.new
     SuckerPunch::Queue.clear_all
     expect(Celluloid::Actor[sucker_punch_actor_name]).to be_nil
   end

    it "does not remove non-SuckerPunch actors from Celluloid registry" do
      class ::OtherJob
        include ::Celluloid
        def self.pool(options); end
        def perform; end
      end
      actor_name = :other_job
      job = OtherJob.new
      Celluloid::Actor[actor_name] = job

      SuckerPunch::Queue.clear_all

      expect(Celluloid::Actor[actor_name]).to eq job
    end
  end

  describe "#register" do
    let(:job) { FakeJob }
    let(:queue) { SuckerPunch::Queue.new(job) }

    it "initializes a celluloid pool" do
      pool = queue.register
      expect(pool.class).to be_a(Celluloid::Supervision::Container::Pool)
    end

    it "registers the pool with Celluloid" do
      expected_pool_name = "#{SuckerPunch::Queue::REGISTRY_PREFIX}_fake_job".to_sym
      pool = queue.register
      expect(Celluloid::Actor[expected_pool_name]).to eq(pool)
    end

    it "registers the pool with Celluloid and 3 workers" do
      expected_pool_name = "#{SuckerPunch::Queue::REGISTRY_PREFIX}_fake_job"
      queue.register(3)
      expect(Celluloid::Actor[expected_pool_name].size).to eq(3)
    end

    context "when too many workers are specified" do
      it "raises a MaxWorkersExceeded exception" do
        expect{ queue.register(201) }.to raise_error(SuckerPunch::Queue::MaxWorkersExceeded)
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

