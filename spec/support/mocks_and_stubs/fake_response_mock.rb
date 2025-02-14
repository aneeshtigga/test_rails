# spec/support/mocks_and_stubs/fake_response_mock.rb

class FakeResponse
  attr_accessor :body

  def initialize
    @body = nil
  end
end
