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
      stopsOnly: true
    }.merge(options)

    query[:q] = CGI.escape name.to_s

    uri = URI('https://ostgotatrafiken.se/ajax/Stops/Find')
    uri.query = query.map do |k, v|
      "#{k}=#{v}"
    end.join '&'

    j = run_query(uri)
    j.map { |v| Stop.new v }
  end

  def self.journey(journey_start, journey_end, options = {})
    query = {
      date: Time.now,
      direction: 0,
      span: :default,
      traffictypes: 63,
      changetime: 0,
      priority: Priority::SHORTEST_TIME,
      walk: false
    }.merge(options)

    journey_start = stops(journey_start).first unless journey_start.is_a? Stop
    journey_end = stops(journey_end).first unless journey_end.is_a? Stop

    raise 'Date must be a Time' unless query[:date].is_a? Time

    query.merge!(
      date: query[:date].strftime('%Y-%m-%d+%H:%M'),

      startId: journey_start.id,
      startType: journey_start.type,
      startLl: journey_start.gps_ll,
      endId: journey_end.id,
      endType: journey_end.type,
      endLl: journey_end.gps_ll
    )

    uri = URI('https://ostgotatrafiken.se/ajax/Journey/Find')
    uri.query = query.map do |k, v|
      "#{k}=#{v}"
    end.join '&'

    j = run_query(uri, error: true)
    j.map { |v| Journey.new v }
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

      first = j.first
      if first.key? :ErrorCode
        raise first[:ErrorText] unless first[:ErrorCode].zero?
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
