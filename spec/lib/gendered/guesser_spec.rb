module Gendered
  describe Guesser do
    let :names do
      ["Sean", "Theresa"]
    end

    subject do
      described_class.new names
    end

    it "is initialized with names" do
      expect(subject.names).to eq names
    end

    it "creates the correct request" do
      params = { "name[]" => names }
      expect(subject).to receive(:request).with(:params => params).and_return(fake_response)
      subject.guess!
    end

    it "cannot be initialized with an empty array" do
      expect{described_class.new([])}.to raise_error ArgumentError
    end

    it "raises an error when over the rate limit" do
      response = fake_response(:code => 429, :usage => { :limit => 1, :remaining => 0, :reset => 2 })
      expect(subject).to receive(:request).and_return(response)
      expect { subject.guess! }.to raise_error(RateLimitError) { |error|
        expect(error.remaining).to eq 0
        expect(error.limit).to eq 1
        expect(error.reset).to eq 2
      }
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

          it "creates the correct request" do
            params = hash_including(:params => { "name[]" => names, option => option })
            expect(subject).to receive(:request).with(params).and_return(fake_response)
            subject.guess!
          end
        end
      end

      context "given the :connection option" do
        subject do
          options = { :apikey => "key", :connection => { :foo => "bar" } }
          Guesser.new(names, options)
        end

        it "is passed to the connection" do
          params = hash_including(:foo => "bar")
          expect(subject).to receive(:request).with(params).and_return(fake_response)
          subject.guess!
        end
      end
    end

    describe "#usage" do
      let :usage do
        { :limit => nil, :remaining => nil, :reset => nil }
      end

      it "has no values until a request is made" do
        expect(subject.usage).to eq usage
      end

      it "is populated after each request" do
        usage.keys.each_with_index { |k, i| usage[k] = i }
        expect(subject).to receive(:request).and_return(fake_response(:usage => usage))
        subject.guess!
        expect(subject.usage).to eq usage

        usage.keys.each { |k| usage[k] += 1 }
        expect(subject).to receive(:request).and_return(fake_response(:usage => usage))
        subject.guess!
        expect(subject.usage).to eq usage
      end
    end

    describe "#guess!" do
      it "returns a valid guesses hash" do
        names = subject.guess!
        names.each do |name|
          expect(name).to be_a Name
        end
      end

      context "when the response's content type is not application/json" do
        it "raises an error" do
          expect(subject).to receive(:request).and_return(fake_response(:content_type => "text/html"))
          expect { subject.guess! }.to raise_error(Gendered::GenderedError, /received a non-JSON response/)
        end
      end

      context "with the name Evat" do
        let :names do
          ["Evat"]
        end

        it "does not error" do
          expect{ subject.guess! }.to_not raise_error
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
end
