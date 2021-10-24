# frozen_string_literal: true

require 'cgi'
require 'json'
require 'logging'
require 'net/http'
require 'ogtraf/connection'
require 'ogtraf/departure'
require 'ogtraf/deviation'
require 'ogtraf/journey'
require 'ogtraf/line'
require 'ogtraf/stop'
require 'ogtraf/version'
require 'uri'

module OGTraf
  module Priority
    SHORTEST_TIME = 0
    FEWER_CHANGES = 1
  end

  def self.stops(name, options = {})
    query = {
      pointType: nil
    }.merge(options)

    query[:q] = CGI.escape name.to_s

    uri = URI('https://rest.ostgotatrafiken.se/stops/Find')
    uri.query = URI.encode_www_form(query)

    j = run_query(uri)
    j.map { |v| Stop.new v }
  end

  def self.departures(departure_start, options = {})
    query = {
      date: nil,
      delay: 0,
      maxNumberOfResultPerColumn: 8,
      columnsPerPageCount: 1,
      pagesCount: 1,
      lines: nil,
      trafficTypes: nil,
      stopPoints: nil
    }.merge(options)

    departure_start = stops(departure_start).first unless departure_start.is_a? Stop

    raise 'Date must be a Time' unless query[:date].is_a? Time

    query.merge!(
      date: query[:date].strftime('%Y-%m-%d+%H:%M'),
      stopAreaId: departure_start.id
    )

    uri = URI('https://rest.ostgotatrafiken.se/stopdepartures/departures')
    uri.query = URI.encode_www_form(query)

    j = run_query(uri)
    j[:groups].first.map { |v| Departure.new v[:Line] }
  end

  def self.journey(journey_start, journey_end, options = {})
    query = {
      date: Time.now,
      direction: 0,
      span: :default,
      traffictypes: 0,
      changetime: 0,
      priority: Priority::SHORTEST_TIME,
      walk: false
    }.merge(options)

    journey_start = stops(journey_start).first unless journey_start.is_a? Stop
    journey_end = stops(journey_end).first unless journey_end.is_a? Stop

    raise 'Date must be a Time' unless query[:date].is_a? Time

    query.merge!(
      time: query[:date].strftime('%H:%M'),
      date: query[:date].strftime('%Y-%m-%d'),

      startId: journey_start.id,
      startType: journey_start.type,
      startLl: journey_start.gps_ll,
      startName: journey_start.name,
      endId: journey_end.id,
      endType: journey_end.type,
      endLl: journey_end.gps_ll,
      endName: journey_end.name
    )

    uri = URI('https://rest.ostgotatrafiken.se/journey/Find')
    uri.query = URI.encode_www_form(query)

    j = run_query(uri, error: true)
    j[:Journeys].map { |v| Journey.new v }
  end

  def self.run_query(uri, _options = {})
    logger.debug uri

    h = Net::HTTP.new(uri.host, uri.port)
    h.use_ssl = uri.scheme == 'https'

    r = h.start do |http|
      http.request(Net::HTTP::Get.new(uri))
    end

    logger.debug r

    begin
      j = JSON.parse(r.body, symbolize_names: true)

      logger.debug j

      raise j unless r.is_a? Net::HTTPSuccess

      if j.is_a? Array
        first = j.first
        if first.key? :ErrorCode
          raise first[:ErrorText] unless first[:ErrorCode].zero?
        end
      end

      j
    rescue JSON::ParserError
      raise "HTTP #{r.code} Response with unparseable JSON."
    end
  end

  def self.debug!
    logger.level = :debug
  end

  def self.logger
    @logger ||= Logging.logger[self].tap do |logger|
      logger.add_appenders Logging.appenders.stdout
      logger.level = :info
    end
  end
end
