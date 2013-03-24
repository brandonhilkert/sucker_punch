require 'spec_helper'
require_relative '../../lib/sucker_punch/testing'

class TestingWorker
  include Celluloid

  def perform(input)
    input = "after"
  end
end

SuckerPunch.config do
  queue name: :queue, worker: TestingWorker
end

describe SuckerPunch do
  let(:var) { "before" }

  describe "testing mixin" do
    it "queues jobs but doesn't perform the work" do
      SuckerPunch::Queue.new(:queue).async.perform(var)
      expect(var).to eq "before"
    end

    describe "#jobs" do
      it "returns number of jobs in the queue" do
        4.times { SuckerPunch::Queue.new(:queue).async.perform(var) }
        queue = SuckerPunch::Queue.new(:queue)
        expect(queue.jobs).to == 4
      end
    end
  end
end
