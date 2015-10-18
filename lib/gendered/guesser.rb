require "json"

module Gendered
  class Guesser
    ENDPOINT = "https://api.genderize.io".freeze

    attr_accessor :names, :options

    def initialize(names, options = {})
      @names = Array(names)
      raise ArgumentError, "names cannot be empty" if @names.empty?

      @options = Gendered.config.merge(options || {})
      @options[:connection] ||= {}
    end

    def guess!
      response = request(request_options)
      guesses = parse(response.body)
      case response.code
      when 200
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
      else
        message = sprintf "%s (%s)", guesses["message"], guesses["code"]
        raise GenderedError.new(message)
      end
    end

    private

    def request_options
      options = {}
      options[:params] = @options.reject { |k, v| k == :connection || v.nil? }
      options[:params]["name[]"] = @names
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
