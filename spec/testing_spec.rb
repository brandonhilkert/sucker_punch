require 'spec_helper'
require_relative '../lib/sucker_punch/testing'

class PatchedWorker
  include SuckerPunch::Worker

  def perform
    "do stuff"
  end
end
SuckerPunch::Queue.new(:patched_queue).register(PatchedWorker, 2)

describe "Testing" do
  let(:queue) { SuckerPunch::Queue.new(:patched_queue) }

  it "processes jobs inline" do
    job = queue.async.perform
    expect(job).to eq "do stuff"
  end
end
