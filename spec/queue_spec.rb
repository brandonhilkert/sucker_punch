require 'spec_helper'

class FakeWorker
  include Celluloid
end
class FakeOtherWorker
  include Celluloid
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
      SuckerPunch::Queue.new(:crazy_queue).register(FakeWorker, 7)
    end

    it "turns the class into an actor" do
      Celluloid::Actor[:crazy_queue].should be_a(Celluloid)
      Celluloid::Actor[:crazy_queue].should be_a(FakeWorker)
      Celluloid::Actor[:crazy_queue].methods.should include(:async)
    end

    it "sets worker size" do
      Celluloid::Actor[:crazy_queue].size.should == 7
    end
  end
end