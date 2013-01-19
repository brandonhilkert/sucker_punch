require 'spec_helper'

class FakeWorker
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
end