module Coincidence
  module GenericBehavior
    attr_reader :pressure

    def initialize(pressure: 5, **)
      @pressure = pressure
    end
  end
end
