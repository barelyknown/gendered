require "json"

module Gendered
  class Guesser

    attr_accessor :names, :options

    def initialize(values, options = {})
      raise ArgumentError, "cannot be empty" if Array(values).empty?

      @names = Array(values)
      @options = Gendered.config.merge(options || {})
      @options[:connection] ||= {}
    end

    def guess!
      response = request(@options[:connection])
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

    # TODO: one can just call HTTP.get(url, :params => { ... })
    def url
      url = "https://api.genderize.io/?"
      query = []

      [:country_id, :language_id, :apikey].each do |param|
        next if @options[param].nil?
        query << sprintf("%s=%s", param.to_s, CGI.escape(@options[param].to_s))
      end

      names.each_with_index do |name, index|
        query << sprintf("name[%s]=%s", index, CGI.escape(name.to_s))
      end

      url << query.join("&")
    end

    private

    def request(options)
      HTTP.get(url, options)
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
