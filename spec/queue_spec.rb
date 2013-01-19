require 'spec_helper'

class FakeWorker
  include Celluloid
end

describe SuckerPunch::Queue do
  describe ".[]" do
    Celluloid::Actor[:fake] = FakeWorker.pool
    pending "figure out what the parent class is"
    # SuckerPunch::Queue[:fake].should be
  end
end