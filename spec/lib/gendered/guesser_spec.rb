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
      expect(subject.url).to eq "https://api.genderize.io/?name[0]=Sean&name[1]=Theresa"
    end

    it "cannot be initialized with an empty array" do
      expect{described_class.new([])}.to raise_error ArgumentError
    end

    describe "options" do
      [:country_id, :language_id, :apikey].each do |option|
        context "given the #{option} option" do
          subject do
            Guesser.new(names, option => option)
          end

          it "is initialized correctly" do
            expect(subject.options[option]).to eq option
          end

          it "creates the correct url" do
            param = "#{option}=#{option}"
            expect(subject.url).to eq "https://api.genderize.io/?#{param}&name[0]=Sean&name[1]=Theresa"
          end
        end
      end

      context "given the :connection option" do
        subject do
          options = { :apikey => "key", :connection => { :foo => "bar" } }
          Guesser.new(names, options)
        end

        it "is passed to the connection" do
          response = double(:body => %|{"a":123}|).as_null_object
          expect(subject).to receive(:request).with(:foo => "bar").and_return(response)

          subject.guess!
        end

        it "creates the correct url" do
          expect(subject.url).to eq "https://api.genderize.io/?apikey=key&name[0]=Sean&name[1]=Theresa"
        end
      end
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

    context "with multiple names that are the same" do
      let :names do
        ["Sean","Sean"]
      end
      it "guesses them both" do
        guesses = subject.guess!
        expect(guesses.collect(&:gender).uniq.size).to eq 1
      end
    end

  end
end
