# frozen_string_literal: true

module OGTraf
  #
  class Line
    attr_reader :name, :number, :note, :operator, :type, :towards, :train_nr,
                :walk

    def initialize(datablock)
      @name = datablock[:LineName]
      @number = datablock[:LineNrReal]
      @note = datablock[:FootNote]
      @operator = {
        id: datablock[:OperatorId],
        name: datablock[:OperatorName]
      }
      @type = datablock[:LineTypeName].to_sym
      @towards = datablock[:Towards]
      @train_nr = datablock[:TrainNo]
      @walk = datablock[:IsWalk]
    end

    def to_s
      @name.to_s
    end
  end
end
