require 'time'

module OGTraf
  #
  class Connection
    attr_reader :departure, :real_departure, :arrival, :real_arrival, :from,
                :to, :line, :deviations

    def initialize(datablock)
      @departure = Time.parse datablock[:DepDateTime]
      @real_departure = @departure

      @arrival = Time.parse datablock[:ArrDateTime]
      @real_arrival = @arrival

      if datablock[:RealTime] && datablock[:RealTime][:RealTimeInfo]
        datablock[:RealTime][:RealTimeInfo].each do |rti|
          @departure += rti[:DepTimeDeviation] * 60
          @arrival += rti[:ArrTimeDeviation] * 60
        end
      end

      @from = Stop.new datablock[:From]
      @to = Stop.new datablock[:To]

      @line = Line.new datablock[:Line]
      @deviations = datablock[:Deviations].map { |d| Deviation.new d }
    end
  end
end
