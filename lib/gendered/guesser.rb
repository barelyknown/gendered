require "json"

module Gendered
  class Guesser
    ENDPOINT = "https://api.genderize.io".freeze
    USAGE_HEADERS = {
      "X-Rate-Limit-Limit" => :limit,
      "X-Rate-Limit-Remaining" => :remaining,
      "X-Rate-Reset" => :reset
    }.freeze

    attr_reader :usage
    attr_accessor :names, :options

    def initialize(names, options = {})
      @names = Array(names)
      raise ArgumentError, "names cannot be empty" if @names.empty?

      @options = Gendered.config.merge(options || {})
      @options[:connection] ||= {}
      @usage = { :limit => nil, :remaining => nil, :reset => nil }
    end

    def guess!
      response = request(request_options)
      update_usage(response)
      body = parse(response.body)
      case response.code
      when 200
        create_names(body)
      when 429
        raise RateLimitError.new(body["error"], *@usage.values_at(:limit, :remaining, :reset))
      else
        raise GenderedError.new(body["error"])
      end
    end

    private

    def update_usage(response)
      USAGE_HEADERS.each { |header, key| @usage[key] = response[header].to_i }
    end

    def create_names(guesses)
      names.collect do |name|
        name = Name.new(name) if name.is_a?(String)
        guess = case
                when guesses.is_a?(Array)
                  guesses.find { |g| g["name"] == name.value }
                else
                  guesses
                end

        if guess["gender"]
          name.gender = guess["gender"].to_sym
          name.probability = guess["probability"]
          name.sample_size = guess["count"]
        end

        name
      end
    end

    def request_options
      options = {}
      options[:params] = @options.reject { |k, v| k == :connection || v.nil? }
      options[:params]["name[]"] = @names.map(&:to_s)
      options[:connection] = @options[:connection] unless @options[:connection].empty?
      options
    end

    def request(options)
      HTTP.get(ENDPOINT, options)
    rescue => e
      raise GenderedError, "request failed: #{e}"
    end

    def parse(response)
      JSON.parse(response)
    rescue JSON::ParserError => e
      raise GenderedError, "cannot parse response JSON: #{e}"
    end
  end
end
