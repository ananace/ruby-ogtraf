require 'time'

module OGTraf
  #
  class Deviation
    attr_reader :header, :summary, :details, :text, :from, :to

    def initialize(datablock)
      @header = datablock[:Header]
      @summary = datablock[:Summary] || datablock[:PublicNote]
      @details = datablock[:Details]
      @text = datablock[:ShortText]

      @from = Time.now
      @to = Time.now

      datablock[:DeviationScopes].each do |dev|
        from = Time.parse dev[:FromDateTime]
        @from = from if @from > from
        to = Time.parse dev[:ToDateTime]
        @to = to if @to < to
      end
    end

    def to_s
      @header.to_s
    end
  end
end
