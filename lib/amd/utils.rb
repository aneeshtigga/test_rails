require "rest-client"

module Amd
  module Utils
    # transforms param keys from { "name" => "xyz" } to { "@name" => "xyz" s}
    def self.transform_param_keys(params)
      params.inject({}) do |result, param|
        result.merge("@#{param.first}" => param.last)
      end
    end
  end
end