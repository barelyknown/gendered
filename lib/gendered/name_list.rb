module Gendered
  class NameList
    include Enumerable

    attr_reader :names

    def initialize(values)
      @names = Array(values).collect do |value|
        case value
        when String then Name.new(value)
        when Name then value
        end
      end
    end

    def guess!(country_id = nil)
      names.each_slice(100).each do |slice|
        Guesser.new(slice).guess!(country_id)
      end
      names.collect(&:gender)
    end

    def each(&block)
      names.each do |name|
        block.call name
      end
    end

    def [](value)
      names.find do |name|
        name.value == value
      end
    end

  end
end
