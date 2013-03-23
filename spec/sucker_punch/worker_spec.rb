require 'spec_helper'

class FakeWorker
  include SuckerPunch::Worker

  def perform
    puts "do stuff"
  end
end

describe SuckerPunch::Worker do
  it "should include Celluloid into requesting class when included" do
    FakeWorker.should respond_to(:pool)
  end
end