module Gendered
  class Guesser

    attr_accessor :names, :country_id

    def initialize(values, country_id = nil)
      raise ArgumentError, "cannot be empty" if Array(values).empty?

      @names = Array(values)
      @country_id = country_id
    end

    def guess!
      response = HTTP.get(url)
      case response.code
      when 200

        guesses = JSON.parse(response.body)

        names.collect do |name|
          name = Name.new(name) if name.is_a?(String)

          guess = guesses.find { |g| g["name"] == name.value }

          if guess["gender"]
            name.gender = guess["gender"].to_sym
            name.probability = guess["probability"]
            name.sample_size = guess["count"]
          end

          name
        end
      end
    end

    def url
      url = "https://api.genderize.io/?"
      url += "country_id=#{country_id}&" if country_id

      name_queries = names.collect.with_index do |name, index|
        "name[#{index}]=#{CGI.escape(name.to_s)}"
      end
      url + name_queries.join("&")
    end
  end
end
