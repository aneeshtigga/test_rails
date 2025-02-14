class RogueConcernException < StandardError
  attr_reader :type
  
  def initialize(msg = "Concern is active but has no age_type", type = "RogueConcernException")
    @type = type
    super(msg)
  end
end