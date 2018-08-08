require 'time'

module OGTraf
  #
  class Journey
    attr_reader :departure, :arrival, :from, :to,
                :real_departure, :real_arrival,
                :connections

    def initialize(datablock)
      @real_departure = Time.parse(datablock[:Departure])
      @real_arrival = Time.parse(datablock[:Arrival])

      @from = Stop.new datablock[:UsedStartPlace]
      @to = Stop.new datablock[:UsedEndPlace]

      @connections = datablock[:Routelinks].map { |r| Connection.new r }

      @departure = @connections.first.departure
      arrival_point = @connections.find { |c| c.to == @to }
      @arrival = @real_arrival
      @arrival = arrival_point.arrival unless arrival_point.nil?
    end

    def on_time?(side = :arr, allowed_drift = 60)
      raise ArgumentError unless
        %i[both dep departure arr arrival].include? side

      if side == :both
        return (@departure - @real_departure).abs < allowed_drift &&
               (@arrival - @real_arrival).abs < allowed_drift
      end

      case side
      when :dep, :departure
        (@departure - @real_departure).abs < allowed_drift
      when :arr, :arrival
        (@arrival - @real_arrival).abs < allowed_drift
      end
    end
  end
end
