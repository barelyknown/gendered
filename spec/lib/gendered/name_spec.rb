module Gendered
  describe Name do

    let :value do
      "Sean"
    end

    subject do
      described_class.new value
    end

    it "initializes with a value" do
      expect(subject.value).to eq value
    end

    describe "#to_s" do
      it "converts with its value" do
        expect(subject.to_s).to eq subject.value
      end
    end

    describe "guess!" do
      it "returns the gender" do
        expect(subject.guess!).to eq :male
      end
    end

    describe "#gender=" do
      described_class::VALID_GENDERS.each do |value|
        it "can set the gender to #{value}" do
          subject.gender = value
          expect(subject.gender).to eq value
        end
      end
      it "raises an argument error if the gender is set to something invalid" do
        %w(eunich).each do |value|
          expect{subject.gender = value}.to raise_error(ArgumentError)
        end
      end
    end

    describe "#gender" do
      it "is not_guessed" do
        expect(subject.gender).to eq :not_guessed
      end
    end

    context "when the gender is male" do
      before { subject.gender = :male }
      it "is male" do
        expect(subject).to be_male
      end
      it "is not female" do
        expect(subject).to_not be_female
      end
    end

    context "when the gender is female" do
      before { subject.gender = :female }
      it "is female" do
        expect(subject).to be_female
      end
      it "is not male" do
        expect(subject).to_not be_male
      end
    end

    context "when the gender is not set" do
      describe "#male?" do
        it "is not_guessed" do
          expect(subject.male?).to eq :not_guessed
        end
      end
      describe "#female?" do
        it "is not_guessed" do
          expect(subject.female?).to eq :not_guessed
        end
      end
    end

    describe "#guessed" do
      context "when the gender is set" do
        before do
          subject.gender = :male
        end
        it "is guessed" do
          expect(subject).to be_guessed
        end
      end
      context "when the gender is not set" do
        it "is not guessed" do
          expect(subject).to_not be_guessed
        end
      end
    end

    describe "#probability=" do
      it "can set probability greater than 0 and less than or equal to 1" do
        probabilities = [BigDecimal("0.01")]
        until probabilities.last == 1
          probabilities << (probabilities.last + BigDecimal("0.01"))
        end
        probabilities.each do |p|
          subject.probability = p
          expect(subject.probability).to eq BigDecimal(p.to_s)
        end
      end
      it "raises an ArgumentError if the value is 0" do
        expect{subject.probability = 0}.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError if the value is greater than 1" do
        expect{subject.probability = 1.01}.to raise_error(ArgumentError)
      end
      it "raises an ArgumentError if the value can't convert to a decimal" do
        expect{subject.probability = "not a decimal"}.to raise_error(ArgumentError)
      end
    end

    describe "#sample_size=" do
      it "raises an ArgumentError if the value can't be converted to an Integer" do
        expect{subject.sample_size = "not an integer"}.to raise_error(ArgumentError)
      end
      it "can set an integer sample size greater than or equal to 0" do
        (0..1).each do |value|
          subject.sample_size = value
          expect(subject.sample_size).to eq value
        end
      end
      it "raises an ArgumentError if the value is less than 0" do
        expect{subject.sample_size = -1}.to raise_error(ArgumentError)
      end
    end

    describe "#probability" do
      it "is :unknown unless set" do
        expect(subject.probability).to eq :unknown
      end
    end

    describe "#sample_size" do
      it "is :unknown unless set" do
        expect(subject.sample_size).to eq :unknown
      end
    end

  end
end
