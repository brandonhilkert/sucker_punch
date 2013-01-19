require 'spec_helper'

class FakeWorker
  include Celluloid
end

describe SuckerPunch do
  context "config" do

    context "properly configured" do
      it "registers the queue" do
        SuckerPunch::Queue.any_instance.should_receive(:register).with(FakeWorker, 7)

        SuckerPunch.config do
          queue name: :crazy_queue, worker: FakeWorker, size: 7
        end
      end
    end

    context "with no queue name" do
      it "raises an exception" do
        expect {
          SuckerPunch.config do
            queue worker: FakeWorker
          end
        }.to raise_error(SuckerPunch::MissingQueueName)
      end
    end

    context "with no worker name" do
      it "raises an exception" do
        expect {
          SuckerPunch.config do
            queue name: :fake
          end
        }.to raise_error(SuckerPunch::MissingWorkerName)
      end
    end

  end
end