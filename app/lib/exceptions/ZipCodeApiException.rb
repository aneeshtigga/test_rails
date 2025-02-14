class ZipCodeApiException < StandardError
    attr_reader :type
    def initialize(msg="ZipCodeApi Error", type="ZipCodeApi")
        @type = type
        super(msg)
    end
end