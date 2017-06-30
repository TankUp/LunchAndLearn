require "spec_helper"

RSpec.describe LunchBot do
  it "has a version number" do
    expect(LunchBot::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
