require "spec_helper"

describe "Core extensions" do
  describe String do
    before :each do
      class FakeQueue; end
    end

    it "underscores a class name" do
      expect(FakeQueue.to_s.underscore).to eq("fake_queue")
    end
  end
end
