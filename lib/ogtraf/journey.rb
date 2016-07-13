require 'time'

module OGTraf
  class Journey
    attr_reader :departure, :arrival, :from, :to
    attr_reader :connections

    def initialize(datablock)
      @departure = Time.parse(datablock[:Departure])
      @arrival = Time.parse(datablock[:Arrival])

      @from = Stop.new datablock[:UsedStartPlace]
      @to = Stop.new datablock[:UsedEndPlace]

      @connections = datablock[:Routelinks].map { |r| Connection.new r }
    end
  end
end
