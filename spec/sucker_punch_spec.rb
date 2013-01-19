require 'spec_helper'

class FakeWorker
  include Celluloid
end

describe SuckerPunch do
  context "config" do
    context "properly configured" do
      before(:all) do
        SuckerPunch.config do
          queue name: :crazy_queue, worker: FakeWorker, size: 7
        end
      end

      it "turns the class into an actor" do
        Celluloid::Actor[:crazy_queue].should be_a(FakeWorker)
        Celluloid::Actor[:crazy_queue].methods.should include(:async)
      end

      it "allow asynchrounous processing" do
      end

      it "sets worker size" do
        Celluloid::Actor[:crazy_queue].size.should == 7
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