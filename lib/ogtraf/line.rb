# frozen_string_literal: true

module OGTraf
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

    def to_json(*args)
      {
        name: @name,
        number: @number,
        note: @note,
        operator: @operator,
        type: @type,
        towards: @towards,
        train_nr: @train_nr,
        walk: @walk
      }.compact.to_json(*args)
    end
  end
end
