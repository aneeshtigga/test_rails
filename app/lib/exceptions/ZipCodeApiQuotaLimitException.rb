class ZipCodeApiQuotaLimitException < StandardError
    attr_reader :type
    def initialize(msg="Quota Limit Reached", type="ZipCodeApiQuotaLimit")
        @type = type
        super(msg)
    end
end