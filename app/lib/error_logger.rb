class ErrorLogger
  def self.report(error, reporter=Bugsnag)
    reporter.notify(error)
  end
end