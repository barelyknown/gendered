module Gendered
  class Guesser

    attr_accessor :names

    def initialize(values)
      raise ArgumentError, "cannot be empty" if Array(values).empty?

      @names = Array(values)
    end

    def guess!
      response = HTTP.get(url)
      case response.code
      when 200
        @names = JSON.parse(response.body).collect do |guess|
          name = names.find { |n| n.to_s == guess["name"] }

          if name.is_a?(String)
            name = Name.new(guess["name"])
          end

          return name unless guess["gender"]

          name.tap do |n|
            n.gender = guess["gender"].to_sym
            n.probability = guess["probability"]
            n.sample_size = guess["count"]
          end
        end
        self.names
      end
    end

    def url
      url = "http://api.genderize.io/?"
      name_queries = names.collect.with_index do |name, index|
        "name[#{index}]=#{CGI.escape(name.to_s)}"
      end
      url + name_queries.join("&")
    end

  end
end
