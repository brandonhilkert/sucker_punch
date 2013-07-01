require 'spec_helper'

describe SuckerPunch::Queue do
  after :each do
    SuckerPunch::Queues.instance_variable_set(:@queues, Set.new)
  end

  describe "#registered?" do
    it "returns true if queue has already been registered" do
      class ::FakeJob
        include SuckerPunch::Job

        def perform(name)
          "response #{name}"
        end
      end

      job = FakeJob.new
      queue = SuckerPunch::Queue.new(job)

      expect{
        queue.register
      }.to change{ queue.registered? }.from(false).to(true)
    end
  end
end

