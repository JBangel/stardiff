module Starbound
  Asset = Struct.new(:name) do
    def initialize(attributes = {})
      attributes.each do |key, value|
        self[key] = value
      end
    end
  end
end
