require 'spec_helper'

class FakeWorker
  include Celluloid
end

describe SuckerPunch do
  context "config" do
    context "done right" do
      before(:all) do
        SuckerPunch.config do
          queue name: :crazy_queue, worker: FakeWorker
        end
      end

      it "defines a pool" do
        # puts Celluloid::Actor[:fake_worker].class
        # Celluloid::Actor[:fake_worker].should be
      end

      it "registers the actor" do
        Celluloid::Actor[:crazy_queue].should be
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