# frozen_string_literal: true

module OGTraf
  class Departure
    attr_reader :from, :to, :time, :real_time, :name, :stops

    def initialize(datablock)
      @from = datablock[:from]
      @to = datablock[:to]
      @time = datablock[:time]
      @real_time = datablock[:real_time]
      @name = datablock[:name]
      @stops = datablock[:stops]
    end

    def to_json(*args)
      {
        from: @from,
        to: @to,
        time: @time,
        real_time: @real_time,
        name: @name,
        stops: @stops
      }.compact.to_json(*args)
    end
  end
end
