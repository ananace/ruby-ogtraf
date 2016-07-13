module OGTraf
  #
  class Stop
    attr_reader :name, :id, :gps, :nice_name, :type

    def initialize(datablock)
      @name = datablock[:PlaceName]
      @id = datablock[:Id]
      @gps = {
        lon: datablock[:Ll][0],
        lat: datablock[:Ll][1]
      }
      @nice_name = datablock[:OgtStopUrlSegment]
      @type = datablock[:OgtType].to_sym
    end

    def gps_ll
      [@gps[:lat], @gps[:lon]].join ','
    end

    def to_s
      "#{@name}"
    end
  end
end
