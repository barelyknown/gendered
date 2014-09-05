module Gendered
  describe Guesser do

    let :names do
      ["Sean","Theresa"]
    end

    subject do
      described_class.new names
    end

    it "is initialized with names" do
      expect(subject.names).to eq names
    end

    it "creates the correct url" do
      expect(subject.url).to eq "http://api.genderize.io/?name[0]=Sean&name[1]=Theresa"
    end

    it "cannot be initialized with an empty array" do
      expect{described_class.new([])}.to raise_error ArgumentError
    end

    describe "#guess!" do
      it "returns a valid guesses hash" do
        names = subject.guess!
        names.each do |name|
          expect(name).to be_a Name
        end
      end
    end

    context "with the name Evat" do
      let :names do
        ["Evat"]
      end
      it "does not error" do
        expect{subject.guess!}.to_not raise_error
      end
    end

  end
end
