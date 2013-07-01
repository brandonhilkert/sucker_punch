require 'spec_helper'
require_relative '../../../lib/sucker_punch/testing/inline'

describe "SuckerPunch Inline Testing" do
  before :each do
    class PatchedJob
      def perform
        "do stuff"
      end
      include SuckerPunch::Job
    end
  end

  it "processes jobs inline" do
    job = PatchedJob.new.async.perform
    expect(job).to eq "do stuff"
  end
end
