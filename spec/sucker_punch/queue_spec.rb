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
    SuckerPunch::Queues.instance_variable_set(:@queues, Set.new)
  end

  describe "#find" do
    it "returns the Celluloid Actor from the registry" do
      job = FakeJob.new
      Celluloid::Actor[:fake_job] = job
      SuckerPunch::Queue.find(job)
      queue = SuckerPunch::Queue.find(job)
      expect(queue).to eq(job)
    end
  end

  describe "#registered?" do
    it "returns true if queue has already been registered" do

      job = FakeJob.new
      queue = SuckerPunch::Queue.new(job)

      expect{
        queue.register
      }.to change{ queue.registered? }.from(false).to(true)
    end
  end
end

