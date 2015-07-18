module Gendered
  describe ".configure" do
    let :settings do
      {
        :apikey      => "key",
        :country_id  => "us",
        :language_id => "en",
        :connection  => { :foo => "bar" }
      }
    end

    it "allows configuration via a block" do
      Gendered.configure do |config|
        settings.each do |name, value|
          config[name] = value
        end
      end

      settings.each do |name, value|
        expect(Gendered.config[name]).to eq value
      end
    end
  end

  describe Config do
    subject do
      Gendered.config
    end

    describe "#merge" do
      it "overrides the default config" do
        subject[:country_id] = "us"
        subject[:language_id] = "en"

        expect(subject.merge(:language_id => "pt")).to eq(:country_id => "us", :language_id => "pt")
      end
    end
  end
end
