module OGTraf
  #
  class Stop
    include Comparable
    attr_reader :name, :id, :gps, :nice_name, :type

    def initialize(datablock)
      @name = datablock[:PlaceName]
      @id = datablock[:Id]
      @gps = {
        lon: datablock[:Ll][0],
        lat: datablock[:Ll][1]
      } if datablock.key?(:Ll) && !datablock[:Ll].nil?
      @nice_name = datablock[:OgtStopUrlSegment]
      @type = datablock[:OgtType].to_sym
    end

    def gps_ll
      [@gps[:lon], @gps[:lat]].join ','
    end

    def to_s
      @name.to_s
    end

    def <=>(other)
      @id <=> other.id
    end
  end
end
