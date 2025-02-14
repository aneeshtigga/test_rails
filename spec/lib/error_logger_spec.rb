require "rails_helper"

RSpec.describe ErrorLogger, type: :class do
  describe ".report" do
    it "reports error to Bugsnag" do
      reporter = double(notify: true)

      ErrorLogger.report("test error", reporter)

      expect(reporter).to have_received(:notify).with("test error")
    end
  end
end
