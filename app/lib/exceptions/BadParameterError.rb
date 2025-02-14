# app/lib/exceptions/BadParameterError.rb

=begin
  The BadParameterError is raised when a method determines that
  it was called with a parameter that was no expected.  For example
  when a parameter is NIL when it was expected to be not NIL.

  Its use is prophylactic in that it protects the
  rest of a method from potential harm when the calling
  parameters are invalid.

  TROUBLESHOOT:

    Most likely a bad data issue.  Review message and
    log entries.  Review method definition.  Fix data
    as necessary.  Potential for business logic to be
    changed to accommodate a different parameter
    value than currently expected.

  Example Usage:

    def verify_cbo(cbo)
      raise(BadParameterError, "CBO cannot be nil") if cbo.nil?
      cbo
    end
=end

class BadParameterError < StandardError
    attr_reader :type
    def initialize(msg="method called with an invalid parameter", type="BadParameterError")
        @type = type
        super(msg)
    end
end