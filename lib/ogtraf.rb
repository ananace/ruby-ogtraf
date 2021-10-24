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
  BASE_URI = URI('https://rest.ostgotatrafiken.se').freeze

  module Priority
    SHORTEST_TIME = 0
    FEWER_CHANGES = 1

    def self.map(symbol)
      return symbol if symbol.is_a? Integer

      case symbol
      when :time, :fastest, :shortest_time
        SHORTEST_TIME
      when :changes, :fewer_changes
        FEWER_CHANGES
      end
    end
  end

  def self.stops(name:, **options)
    uri = URI("#{BASE_URI}/stops/Find")
    uri.query = URI.encode_www_form(
      q: CGI.escape(name.to_s),

      pointType: options.fetch(:point_type, nil)
    )

    run_query(uri).map { |v| Stop.new v }
  end

  def self.departures(from:, date: Time.now, **options)
    raise 'Date must be a Time' unless query[:date].is_a? Time

    from = stops(name: from).first unless from.is_a? Stop

    uri = URI("#{BASE_URI}/stopdepartures/departures")
    uri.query = URI.encode_www_form(
      date: date.strftime('%Y-%m-%d+%H:%M'),
      stopAreaId: from.id,

      delay: options.fetch(:delay, 0),
      maxNumberOfResultPerColumn: options.fetch(:max_reults, 8),
      columnsPerPageCount: options.fetch(:per_page, 1),
      pagesCount: options.fetch(:page_count, 1),
      lines: options.fetch(:lines, nil),
      trafficTypes: options.fetch(:traffic_types, nil),
      stopPoints: options.fetch(:stops, nil)
    )

    run_query(uri)[:groups].first.map { |v| Departure.new v[:Line] }
  end

  def self.journey(from:, to:, date: Time.now, **options)
    raise 'Date must be a Time' unless date.is_a? Time

    from = stops(name: from).first unless from.is_a? Stop
    to = stops(name: to).first unless to.is_a? Stop

    uri = URI("#{BASE_URI}/journey/Find")
    uri.query = URI.encode_www_form(
      time: date.strftime('%H:%M'),
      date: date.strftime('%Y-%m-%d'),

      changetime: options.fetch(:changetime, 0),
      direction: options.fetch(:direction, 0),
      priority: Priority.map(options.fetch(:priority, :time)),
      span: options.fetch(:span, :default),
      traffictypes: options.fetch(:traffictypes, 0),
      walk: options.fetch(:walk, false),

      startId: from.id,
      startType: from.type,
      startLl: from.gps_ll,
      startName: from.name,
      endId: to.id,
      endType: to.type,
      endLl: to.gps_ll,
      endName: to.name
    )

    run_query(uri, error: true)[:Journeys].map { |v| Journey.new v }
  end

  def self.run_query(uri, _options = {})
    req = Net::HTTP::Get.new(uri)
    logger.debug "< #{req.method} #{req.uri}"
    req.each_header { |header| logger.debug "< #{header}: #{req[header]}" }
    logger.debug '<'

    resp = http_req(req)

    logger.debug "> #{resp.code} #{resp.msg}"
    resp.each_header { |header| logger.debug "> #{header}: #{resp[header]}" }
    logger.debug '>'

    begin
      data = JSON.parse(resp.body, symbolize_names: true)
      raise data unless resp.is_a? Net::HTTPSuccess

      if data.is_a? Array
        first = data.first
        raise first[:ErrorText] if first.key?(:ErrorCode) && !first[:ErrorCode].zero?
      end

      data
    rescue JSON::ParserError
      raise "HTTP #{resp.code} Response with unparseable JSON."
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

  class << self
    private

    def http_req(req)
      @http ||= Net::HTTP.new(BASE_URI.host, BASE_URI.port)
      @http.use_ssl = BASE_URI.scheme == 'https'
      @http.start unless @http.started?
      @http.request req
    end
  end
end
