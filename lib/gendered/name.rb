module Gendered
  class Name
    VALID_GENDERS = %i(male female)

    attr_reader :value

    def initialize(value)
      @value = value

      @gender, @probability, @sample_size = nil, nil, nil
    end

    alias_method :to_s, :value

    def guessed?
      !!@gender
    end

    def guess!(country_id = nil)
      Guesser.new(self, country_id).guess!
      gender
    end

    def probability=(value)
      decimal = BigDecimal(value.to_s)
      raise ArgumentError, "value not between 0.01 and 1.0" if decimal <= 0 || decimal > 1

      @probability = decimal
    end

    def probability
      @probability || :unknown
    end

    def sample_size=(value)
      integer = Integer(value)
      raise ArgumentError, "value not greater than or equal to 0" if integer < 0

      @sample_size = integer
    end

    def sample_size
      @sample_size || :unknown
    end

    def gender=(value)
      symbol = value.to_sym
      raise ArgumentError, "not a valid gender" unless VALID_GENDERS.include?(symbol)
      @gender = symbol
    end

    def gender
      @gender || :not_guessed
    end

    def male?
      return :not_guessed unless guessed?
      gender == :male
    end

    def female?
      return :not_guessed unless guessed?
      gender == :female
    end

  end
end
