require 'spec_helper'

class TestingWorker
  include Celluloid

  def perform(input)
    input = "after"
  end
end

SuckerPunch.config do
  queue name: :queue, worker: TestingWorker
end

describe "SuckerPunch Testing" do
  before :each do
    require_relative '../../lib/sucker_punch/testing'
    SuckerPunch.reset!
  end

  describe ".reset!" do
    it "resets the queues to be empty" do
      4.times { SuckerPunch::Queue.new(:queue).async.perform("before") }
      SuckerPunch.reset!
      queue = SuckerPunch::Queue.new(:queue)
      expect(queue.jobs.count).to eq 0
    end
  end

  describe Queue do
    it "returns previous instance when queried again" do
      queue = SuckerPunch::Queue.new(:queue)
      queue.async.perform("before")
      expect(SuckerPunch::Queue.new(:queue).jobs.count).to eq 1
    end

    describe ".[]" do
      it "returns the queue instance" do
        queue = SuckerPunch::Queue.new(:queue)
        queue.async.perform("before")
        expect(SuckerPunch::Queue[:queue].jobs.count).to eq 1
      end
    end

    describe "#register" do
      it "returns nil" do
        queue = SuckerPunch::Queue.new(:queue)
        expect(queue.register(TestingWorker, 3)).to eq nil
      end
    end

    describe "#workers" do
      it "raises an exception if called" do
        queue = SuckerPunch::Queue.new(:queue)
        expect{ queue.workers }.to raise_error "Not implemented"
      end
    end

    describe "#jobs" do
      it "returns an array of the jobs in the queue" do
        queue = SuckerPunch::Queue.new(:queue)
        queue.async.perform("before")
        expect(queue.jobs).to eq [{ method: :perform, args: ["before"] }]
      end

      it "returns the number of jobs in the queue" do
        queue = SuckerPunch::Queue.new(:queue)
        4.times { queue.async.perform("before") }
        expect(queue.jobs.count).to eq 4
      end
    end

    describe "#async" do
      it "returns self" do
        queue = SuckerPunch::Queue.new(:queue)
        expect(queue.async).to eq queue
      end
    end

    describe "enqueueing a job" do
      it "adds the job to the queue" do
        queue = SuckerPunch::Queue.new(:queue)
        queue.async.perform("before")
        expect(queue.jobs).to eq [{ method: :perform, args: ["before"] }]
      end
    end
  end
end
