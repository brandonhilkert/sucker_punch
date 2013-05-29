require 'spec_helper'

class FakeWorker
  include Celluloid
end

class FakeWorkerWithArgs
  include Celluloid

  attr_reader :passed_arg
  def initialize(arg)
    @passed_arg = arg
    super()
  end
end

describe SuckerPunch::Queue do
  describe ".[]" do
    it "delegates to Celluloid" do
      Celluloid::Actor[:fake] = FakeWorker.pool
      Celluloid::Actor.should_receive(:[]).with(:fake)
      SuckerPunch::Queue[:fake]
    end
  end

  describe "#register" do
    before(:each) do
      SuckerPunch::Queue.new(:crazy_queue).register(FakeWorker, 2)
    end

    it "turns the class into an actor" do
      Celluloid::Actor[:crazy_queue].should be_a(Celluloid)
      Celluloid::Actor[:crazy_queue].should be_a(FakeWorker)
      Celluloid::Actor[:crazy_queue].methods.should include(:async)
    end

    it "sets worker size" do
      Celluloid::Actor[:crazy_queue].size.should == 2
    end
  end

  describe "#workers" do
    it "returns number of workers" do
      SuckerPunch::Queue.new(:crazy_queue).register(FakeWorker, 2)
      SuckerPunch::Queue.new(:crazy_queue).workers.should == 2
    end
  end

  describe "delegation" do
    let(:queue) { SuckerPunch::Queue.new(:crazy_queue) }

    before(:each) do
      SuckerPunch::Queue.new(:crazy_queue).register(FakeWorker, 2)
    end

    it "sends messages to Actor" do
      queue.size.should == 2
      queue.idle_size.should == 2
      queue.busy_size.should == 0
    end
  end

  describe "worker arguments" do
    let(:queue) { SuckerPunch::Queue.new(:crazy_queue) }

    before(:each) do
      SuckerPunch::Queue.new(:crazy_queue).register(FakeWorkerWithArgs, 2, :arg)
    end

    it "passes args to worker" do
      queue.passed_arg.should == :arg
    end
  end
end
