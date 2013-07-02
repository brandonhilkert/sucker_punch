require 'spec_helper'

describe SuckerPunch::Job do
  before :each do
    class ::FakeJob
      include SuckerPunch::Job

      def perform(name)
        "response #{name}"
      end
    end
  end

  it "includes Celluloid into requesting class when included" do
    FakeJob.should respond_to(:pool)
  end

  describe "#perform" do
    context "when pool hasn't been created" do
      it "creates pool and registers queue" do
        expect(Celluloid::Actor[:fake_job]).to eq(nil)
        expect(SuckerPunch::Queues.all).to eq([])

        # Don't use #async here b/c of a race condition
        # The expectation will run before the asynchronous
        # job is executed
        FakeJob.new.perform("test")

        expect(Celluloid::Actor[:fake_job]).to be
        expect(SuckerPunch::Queues.all).to eq([:fake_job])
      end
    end
  end
end
