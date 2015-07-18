module Gendered
  describe NameList do
    subject do
      described_class.new values
    end

    let :values do
      ["Sean", "Theresa"] * 50
    end

    describe "#guess!" do
      it "guesses correctly" do
        guesser = double(Guesser)
        expect(guesser).to receive(:guess!)
        expect(Guesser).to receive(:new).with(subject.names, {}).and_return(guesser)
        subject.guess!
      end

      it "guesses correctly with country_id" do
        subject = described_class.new(values, :country_id => "us")
        guesser = double(Guesser)
        expect(guesser).to receive(:guess!)
        expect(Guesser).to receive(:new).with(subject.names, :country_id => "us").and_return(guesser)
        subject.guess!
      end
    end

    context "when the values are strings" do
      it "sets the names" do
        subject.names.each.with_index do |name, index|
          expect(name.value).to eq values[index]
        end
      end
    end

    context "when the values are names" do
      let :values do
        [Name.new("Sean"), Name.new("Theresa")]
      end

      it "sets the names" do
        expect(subject.names).to eq values
      end
    end
  end
end
